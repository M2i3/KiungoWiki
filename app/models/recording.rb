class Recording 
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search
  include Mongoid::History::Trackable

#TODO: Re-enable some form of versioning most likely using https://github.com/aq1018/mongoid-history instead of the Mongoid::Versioning module
  field :signature, type:  String
  field :title, type:  String
  field :recording_date, type:  IncDate
  field :recording_location, type:  String
  field :duration, type:  Duration
  field :rythm, type:  Integer
  field :origrecordingid, type:  String
  field :missing_tags, type: Boolean
  field :missing_supplementary_sections, type: Boolean

  #
  # calculated values so we can index and sort
  #
  field :cache_normalized_title, type:  String, default: ""
  field :cache_first_letter, type:  String, default: ""

  before_save :update_cached_fields

  index({ signature: 1 }, { background: true })
  index({ cache_normalized_title: 1 }, { background: true })
  index({ cache_first_letter: 1, cache_normalized_title: 1 }, { background: true })
  index({ origrecordingid: 1})

  search_in :title, {match: :all}

  validates :duration_text, duration: {allow_nil: true}
  
  validates_presence_of :work_wiki_link
#  validates_length_of :work_title, :in=>1..500, :allow_nil=>true
#  validates_numericality_of :duration, :greater_than=>0, :allow_nil=>true  
#  validates_format_of :recording_date_text, :with=>/^(\d{4})(?:-?(\d{0,2})(?:-?(\d{0,2}))?)?$/, :allow_nil=>true
  validates_numericality_of :rythm, greater_than: 0, allow_nil: true

  embeds_one :work_wiki_link, as: :linkable, class_name: "RecordingWorkWikiLink"
  validates_associated :work_wiki_link  
  accepts_nested_attributes_for :work_wiki_link, allow_destroy: true

  embeds_many :artist_wiki_links, as: :linkable, class_name: "RecordingArtistWikiLink"
  accepts_nested_attributes_for :artist_wiki_links, allow_destroy: true
  validates_associated :artist_wiki_links

  embeds_many :release_wiki_links, as: :linkable, class_name: "RecordingReleaseWikiLink"
  accepts_nested_attributes_for :release_wiki_links, allow_destroy: true
  validates_associated :release_wiki_links

  embeds_many :category_wiki_links, as: :linkable
  accepts_nested_attributes_for :category_wiki_links, allow_destroy: true
  validates_associated :category_wiki_links

  embeds_many :supplementary_sections, class_name: "SupplementarySection"
  accepts_nested_attributes_for :supplementary_sections
  validates_associated :supplementary_sections

  embeds_many :tags, as: :taggable, class_name: "PublicTag"
  has_many :user_tags, as: :taggable, class_name: "UserTag"
  
  # telling Mongoid::History how you want to track changes
  track_history   modifier_field: :modifier, # adds "referenced_in :modifier" to track who made the change, default is :modifier
                  version_field: :version,   # adds "field :version, type:  Integer" to track current version, default is :version
                  track_create:  true,    # track document creation, default is false
                  track_update:  true,     # track document updates, default is true
                  track_destroy:  true     # track document destruction, default is false



  def release_title
    self.release_wiki_link.title 
  end

  def work_wiki_link_text
    (work_wiki_link && work_wiki_link.reference_text) || ""
  end

  def work_wiki_link_combined_link
    work_wiki_link && [work_wiki_link.combined_link]
  end

  def work_wiki_link_text=(value)
    self.work_wiki_link = WorkWikiLink.new({reference_text: value})
  end

  def artist_wiki_links_text
    artist_wiki_links.collect{|v| v.reference_text }.join("||")
  end

  def artist_wiki_links_combined_links
    artist_wiki_links.collect{|v| v.combined_link }
  end

  def artist_wiki_links_text=(value)
    links = []
    value.split("||").each{|q| 
      links << RecordingArtistWikiLink.new(reference_text: q.strip) 
    }
    self.artist_wiki_links = links
  end

  def first_artist_object_text
    self.artist_wiki_links.first && self.artist_wiki_links.first.name
    #TODO: Fix artist name display
  end

  def release_wiki_links_text
    release_wiki_links.collect{|v| v.reference_text }.join("||")
  end

  def release_wiki_links_combined_links
    release_wiki_links.collect{|v| v.combined_link }
  end

  def release_wiki_links_text=(value)
    links = []
    value.split("||").each{|q| 
      links << RecordingReleaseWikiLink.new(reference_text: q.strip) 
    }
    self.release_wiki_links = links
  end

  def category_wiki_links_text
    category_wiki_links.collect{|v| v.reference_text }.join("||")
  end

  def category_wiki_links_combined_links
    category_wiki_links.collect{|v| v.combined_link }
  end

  def category_wiki_links_text=(value)
    links = []
    value.split("||").each{|q| 
      links << CategoryWikiLink.new(reference_text: q.strip) 
    }
    self.category_wiki_links = links 
  end

  def category_name
    unless["0","",nil].include?(self.category_wiki_links)
      self.category_wiki_links.collect{|v| v.category_name}.join(', ')
    else
      "unknown"
    end
  end
  
  def add_supplementary_section
    self.supplementary_sections << SupplementarySection.new()
  end

  def normalized_title
    self.title.to_s.
      mb_chars.
      normalize(:kd).
      to_s.
      gsub(/[._:;'"`,?|+={}()!@#%^&*<>~\$\-\\\/\[\]]/, ' '). # strip punctuation
      gsub(/[^[:alnum:]\s]/,'').   # strip accents
      downcase.strip
  end

  def title_first_letter
    first_letter = self.normalized_title[0] || ""
    first_letter = "#" if ("0".."9").include?(first_letter)
    first_letter
  end

  def update_cached_fields
    self[:title] = self.work_wiki_link.title 
    self.cache_normalized_title = self.normalized_title
    self.cache_first_letter = self.title_first_letter
    self.signature = self.to_search_query.signature
  end

  def to_wiki_link(klass=RecordingWikiLink)
    klass.new(reference_text: self.to_search_query.q, recording: self)
  end
    
  def to_search_query
    sq = RecordingWikiLink::SearchQuery.new
    RecordingWikiLink::SearchQuery::QUERY_ATTRS.keys.each {|key|
      sq[key] = self[key]
    }
    sq
  end
  
  def user_tags_text
    UserTagsWorker.new self
  end
  
  def tokenized_user_tags user
    self.user_tags.where(user:user).collect{|tag| {id:tag.name, name:tag.name} }.to_json
  end

  scope :queried, ->(q) {
    current_query = all
    rsq = RecordingWikiLink.search_query(q)
    rsq.filled_query_fields.each {|field|
      case field
        when :oid
          current_query = current_query.where(:_id=>rsq[field])
        when :title
          current_query = current_query.csearch(rsq[field], match: :all)
        when :category_name
          current_query = current_query.where(field=>/#{Regexp.quote(rsq[field].downcase)}/i)
        when :created_at, :duration, :recording_date, :rythm, :update_at
          current_query = current_query.where(field=>rsq[field])        
      end 
    }
    current_query
  }
  
  after_destroy do |doc|
    attrs = "" 
    RecordingWikiLink::SearchQuery::QUERY_ATTRS.keys.each {|attri| attrs += "#{attri}: \"#{doc.send(attri)}\" "}
    [Artist, Release, Work].each do |klass|
      klass.where("recording_wiki_links.recording_id" => doc.id).all.each do |rec|
        rec.recording_wiki_links.each do |recording|
          if recording.recording_id == doc.id
            recording.recording_id = nil
            recording.reference_text = attrs
            recording.save!
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
  
end
