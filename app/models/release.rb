class Release
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search
  include Mongoid::History::Trackable

  field :title, type: String
  field :date_released, type: IncDate
  field :label, type: String
  field :media_type, type: String
  field :reference_code, type: String
  field :number_of_recordings, type: Integer
  field :origalbumid, type: String
  field :alpha_ordering, type: String
  field :numerical_ordering, type: Integer
  field :missing_supplementary_sections, type: Boolean

  #
  # calculated values so we can index and sort
  #
  field :cache_normalized_title, type: String, default: ""
  field :cache_first_letter, type: String, default: ""

  before_save :update_cached_fields

  index({ cache_normalized_title: 1 }, { background: true })
  index({ cache_first_letter: 1, cache_normalized_title: 1 }, { background: true })

  search_in :title, :label, {match: :all}

  validates_presence_of :title

  embeds_many :artist_wiki_links, as: :linkable, class_name: "ReleaseArtistWikiLink", cascade_callbacks: true
  accepts_nested_attributes_for :artist_wiki_links, allow_destroy: true
  validates_associated :artist_wiki_links

  embeds_many :recording_wiki_links, as: :linkable, class_name: "ReleaseRecordingWikiLink", cascade_callbacks: true
  accepts_nested_attributes_for :recording_wiki_links, allow_destroy: true
  validates_associated :recording_wiki_links

  embeds_many :supplementary_sections, class_name: "SupplementarySection", cascade_callbacks: true
  accepts_nested_attributes_for :supplementary_sections, allow_destroy: true
  validates_associated :supplementary_sections
  
  embeds_many :tags, as: :taggable, class_name: "PublicTag"
  
  has_many :user_tags, as: :taggable

  # telling Mongoid::History how you want to track changes
  track_history   modifier_field: :modifier, # adds "referenced_in :modifier" to track who made the change, default is :modifier
                  version_field:  :version,   # adds "field :version, :type => Integer" to track current version, default is :version
                  track_create:     true,    # track document creation, default is false
                  track_update:     true,     # track document updates, default is true
                  track_destroy:    true     # track document destruction, default is false


  def artist_wiki_links_text
    artist_wiki_links.collect{|v| v.reference_text }.join("||")
  end

  def artist_wiki_links_combined_links
    artist_wiki_links.collect{|v| v.combined_link }
  end

  def artist_wiki_links_text=(value)
    links = []
    value.split("||").each{|q| 
      links << ReleaseArtistWikiLink.new(reference_text: q.strip) 
    }
    self.artist_wiki_links = links
  end

  def first_artist_display_text
    self.artist_wiki_links.first && self.artist_wiki_links.first.display_text
  end
  
  def recording_wiki_links_text
    recording_wiki_links.collect{|v| v.reference_text }.join("||")
  end

  def recording_wiki_links_combined_links
    recording_wiki_links.collect{|v| v.combined_link }
  end

  def recording_wiki_links_combined_links_renamed
    mappings = {title: :name}
    recording_wiki_links_combined_links.collect do |x|
      Hash[x.map {|k,v| [mappings[k] || k, v] }]
    end
  end

  def recording_wiki_links_text=(value)
    links = []
    value.split("||").each{|q| 
      links << ReleaseRecordingWikiLink.new(reference_text: q.strip) 
    }
    self.recording_wiki_links = links
  end

  def add_supplementary_section
    self.supplementary_sections << SupplementarySection.new()
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
    ReleaseWikiLink.new(reference_text: "oid:#{self.id}", release: self)
  end
  
  def user_tags_text
    UserTagsWorker.new self
  end
  
  def tokenized_user_tags user
    self.user_tags.where(user:user).collect{|tag| {id:tag.name, name:tag.name} }.to_json
  end
  
  scope :queried, ->(q) {
    current_query = all
    asq = ReleaseWikiLink.search_query(q)
    asq.filled_query_fields.each {|field|
      case field
        when :title
          current_query = current_query.csearch(asq[field], match: :all)
        when :label, :media_type, :reference_code
          current_query = current_query.where(field=>/#{Regexp.quote(asq[field].downcase)}/i)
        when :date_released, :created_at, :updated_at
          current_query = current_query.where(field=>asq[field])        
      end 
    }
    current_query
  }
  
  after_destroy do |doc|
    attrs = "" 
    ReleaseWikiLink::SearchQuery::QUERY_ATTRS.keys.each {|attri| attrs += "#{attri}: \"#{doc.send(attri)}\" "}
    [Artist, Recording].each do |klass|
      klass.where("release_wiki_links.release_id" => doc.id).all.each do |rec|
        rec.release_wiki_links.each do |release|
          if release.release_id == doc.id
            release.release_id = nil
            release.reference_text = attrs
            release.save!
          end
        end
      end
    end
  end
  
  before_save do |doc|
    doc.missing_supplementary_sections = doc.supplementary_sections.length == 0
    true
  end

  #Release.all.group_by {|a| a.title_first_letter.upcase }.sort{|a, b| a <=> b}.each {|a| puts "* [" + a[0] + "] - " + a[1][0..4].collect{|b| "[" + b.title + "]"}.join(", ") + (a[1][5] ? ", [...]": "") }; nil
  #Release.all.group_by {|a| a.date_released.year.to_s }.sort{|a, b| a <=> b}.each {|a| puts "* [" + a[0] + "] - " + a[1][0..4].collect{|b| "[" + b.title + "]"}.join(", ") + (a[1][5] ? ", [...]": "") }; nil
  #Release.all.group_by {|a| a.date_released.year.to_s }.sort{|a, b| a <=> b}.each {|a| puts "" + a[0] + ", " + a[1].length.to_s }; nil
end
