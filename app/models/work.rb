class Work
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search
  include Mongoid::History::Trackable

  #
  # basic entity information
  #
  field :title, type: String, default: ""
  field :date_written, type: IncDate
  field :copyright, type: String
  field :language_code, type: String
  field :publisher, type: String
  field :lyrics, type: String
  field :chords, type: String
  field :origworkid, type: String
  field :is_lyrics_verified, type: Integer
  field :is_credits_verified, type: Integer
  field :missing_tags, type: Boolean
  field :missing_supplementary_sections, type: Boolean
  field :publishers, type: Array, default: []

  #
  # calculated values so we can index and sort
  #
  field :cache_normalized_title, type: String, default: ""
  field :cache_first_letter, type: String, default: ""

  before_save :update_cached_fields

  index({ cache_normalized_title: 1 }, { background: true })
  index({ cache_first_letter: 1, cache_normalized_title: 1 }, { background: true })

  search_in :title, {match: :all}

  validates_presence_of :title

  embeds_many :artist_wiki_links, as: :linkable, class_name: "WorkArtistWikiLink"
  validates_associated :artist_wiki_links
  accepts_nested_attributes_for :artist_wiki_links

  embeds_many :recording_wiki_links, as: :linkable, class_name: "WorkRecordingWikiLink"
  accepts_nested_attributes_for :recording_wiki_links
  validates_associated :recording_wiki_links

  embeds_many :work_wiki_links, as: :linkable, class_name: "WorkWorkWikiLink"
  accepts_nested_attributes_for :work_wiki_links
  validates_associated :work_wiki_links

  embeds_many :supplementary_sections, class_name: "SupplementarySection"
  accepts_nested_attributes_for :supplementary_sections
  validates_associated :supplementary_sections
  
  embeds_many :tags, as: :taggable, class_name: "PublicTag"
  
  has_many :user_tags, as: :taggable

  # telling Mongoid::History how you want to track changes
  track_history   modifier_field: :modifier, # adds "referenced_in :modifier" to track who made the change, default is :modifier
                  version_field: :version,   # adds "field :version, :type => Integer" to track current version, default is :version
                  track_create:  true,    # track document creation, default is false
                  track_update:  true,     # track document updates, default is true
                  track_destroy:  true     # track document destruction, default is false


  def artist_wiki_links_text
    artist_wiki_links.collect{|v| v.reference_text }.join(",")
  end

  def artist_wiki_links_combined_links
    artist_wiki_links.collect{|v| v.combined_link }
  end

  def artist_wiki_links_text=(value)
    links = []
    value.split(",").each{|q| 
      links << WorkArtistWikiLink.new(:reference_text=>q.strip) 
    }    
    self.artist_wiki_links = links
  end

  def first_artist_object_text
    self.artist_wiki_links.first && self.artist_wiki_links.first.name(true)
  end

  def recording_wiki_links_text
    recording_wiki_links.collect{|v| v.reference_text }.join(",")
  end

  def recording_wiki_links_combined_links
    recording_wiki_links.collect{|v| v.combined_link }
  end

  def recording_wiki_links_combined_links_renamed
    mappings = {:title => :name}
    recording_wiki_links_combined_links.collect do |x|
      Hash[x.map {|k,v| [mappings[k] || k, v] }]
    end
  end

  def recording_wiki_links_text=(value)
    links = []
    value.split(",").each{|q| 
      links << WorkRecordingWikiLink.new(:reference_text=>q.strip) 
    }
    self.recording_wiki_links = links
  end

  def work_wiki_links_text
    work_wiki_links.collect{|v| v.reference_text }.join(",")
  end

  def work_wiki_links_combined_links
    work_wiki_links.collect{|v| v.combined_link }
  end

  def work_wiki_links_text=(value)
    links = []
    value.split(",").uniq.each{|q| 
      links << WorkWorkWikiLink.new(:reference_text=>q.strip) 
    }
    self.work_wiki_links = links    
  end

  def add_supplementary_section
    self.supplementary_sections << SupplementarySection.new()
  end

  def language_name
    unless["0","",nil].include?(Language.where(:language_code=>self.language_code).first); 
                Language.where(:language_code=>self.language_code).first[:language_name_french]; 
    end
  end

  def normalized_title
    self.title.to_s.
      mb_chars.
      normalize(:kd).
      to_s.
      gsub(/[._:;'"`,?|+={}()!@#%^&*<>~\$\-\\\/\[\]\s+]/, ''). # strip punctuation
      gsub(/[^[:alnum:]\s]/,'').   # strip accents
      downcase.strip
  end

  def title_first_letter
    first_letter = self.normalized_title[0] || ""
    first_letter = "#" if ("0".."9").include?(first_letter)
    first_letter
  end

  def update_cached_fields
    self.cache_normalized_title = self.normalized_title
    self.cache_first_letter = self.title_first_letter
  end

  def to_wiki_link
    WorkWikiLink.new(:reference_text=>"oid:#{self.id}", :work=>self)
  end
  
  def user_tags_text
    UserTagsWorker.new self
  end
  
  def tokenized_user_tags user
    self.user_tags.where(user:user).collect{|tag| {id:tag.name, name:tag.name} }.to_json
  end
  
  def publishers_text
    self.publishers.join(", ")
  end

  def publishers_text=(value)
    self.publishers.clear
    value.split(",").each{|q| 
      self.publishers << q
    }    
  end
  
  def tokenized_publishers
    tokenized = []
    self.publishers.each {|publisher| tokenized << {id:publisher, name:publisher}}
    tokenized.to_json
  end

  scope :queried, ->(q) {
    current_query = all
    wsq = WorkWikiLink.search_query(q)
    wsq.filled_query_fields.each {|field|
      case field
        when :title
          current_query = current_query.csearch(wsq[field], match: :all)
        when :publisher, :copyright, :language_code, :lyrics
          current_query = current_query.where(field=>/#{wsq[field].downcase}/i)
        when :date_written, :created_at, :updated_at
          current_query = current_query.where(field=>wsq[field])        
      end 
    }
    current_query
  }

  after_destroy do |doc|
    attrs = "" 
    WorkWikiLink::SearchQuery::QUERY_ATTRS.keys.each {|attri| attrs += "#{attri}: \"#{doc.send(attri)}\" "}
    [Artist, Recording, Work].each do |klass|
      klass.where("work_wiki_links.work_id" => doc.id).all.each do |rec|
        rec.work_wiki_links.each do |work|
          if work.work_id == doc.id
            work.work_id = nil
            work.reference_text = attrs
            work.save!
          end
        end
      end
    end
  end
  
  before_save do |doc|
    doc.missing_tags = doc.tags.length == 0
    doc.missing_supplementary_sections = doc.supplementary_sections.length == 0
    true
  end
  
  after_save do |doc|    
    if doc.changes.has_key? "publishers"
      publisher_changes = doc.changes["publishers"]
      original = publisher_changes[0]
      new_publishers = publisher_changes[1]
      original = [] if original.nil?
      # new labels
      (new_publishers.reject{|pub| original.include? pub }).each do |publisher|
        Publisher.where(name:publisher).first_or_create!.inc(:count, 1)
      end
      # deleted labels
      (original.reject{|pub| new_publishers.include? pub }).each do |publisher|
        found = Publisher.where(name:publisher).first
        found.inc(:count, -1) if found # backwards compatiable
      end
    end
  end
  
  #Work.all.group_by {|a| a.title_first_letter.upcase }.sort{|a, b| a <=> b}.each {|a| puts "* [" + a[0] + "] - " + a[1][0..4].collect{|b| "[" + b.title + "]"}.join(", ") + (a[1][5] ? ", [...]": "") }; nil
end


