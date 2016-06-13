class Artist 
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search
  include Mongoid::History::Trackable

#TODO: Re-enable some form of versioning most likely using https://github.com/aq1018/mongoid-history instead of the Mongoid::Versioning module

  field :signature, type:  String
  field :name, type:  String
  field :surname, type:  String, default:  ""
  field :given_name, type:  String, default:  ""
  field :birth_date, type:  IncDate
  field :birth_location, type:  String
  field :death_date, type:  IncDate
  field :death_location, type:  String
  field :origartistid, type:  String
  field :is_group, type:  Integer
  field :missing_supplementary_sections, type: Boolean


  #
  # calculated values so we can index and sort
  #
  field :cache_normalized_name, type:  String, default:  ""
  field :cache_first_letter, type:  String, default:  ""

  before_save :update_cached_fields

  index({ signature: 1 }, { background: true })
  index({ cache_normalized_name: 1 }, { background: true })
  index({ cache_first_letter: 1, cache_normalized_name: 1 }, { background: true })
  index({ origartistid: 1})

  search_in :name, :surname, :given_name, :birth_location, :death_location, {match: :all}

  validates_presence_of :surname

  embeds_many :work_wiki_links, as: :linkable, class_name: "ArtistWorkWikiLink"
  validates_associated :work_wiki_links
  accepts_nested_attributes_for :work_wiki_links, allow_destroy: true

  embeds_many :release_wiki_links, as: :linkable, class_name: "ArtistReleaseWikiLink"
  validates_associated :release_wiki_links
  accepts_nested_attributes_for :release_wiki_links, allow_destroy: true

  embeds_many :recording_wiki_links, as: :linkable, class_name: "ArtistRecordingWikiLink"
  validates_associated :recording_wiki_links
  accepts_nested_attributes_for :recording_wiki_links, allow_destroy: true

  embeds_many :artist_wiki_links, as: :linkable, class_name: "ArtistArtistWikiLink"
  validates_associated :artist_wiki_links
  accepts_nested_attributes_for :artist_wiki_links, allow_destroy: true

  embeds_many :supplementary_sections, class_name: "SupplementarySection"
  validates_associated :supplementary_sections
  accepts_nested_attributes_for :supplementary_sections, allow_destroy: true
    
  embeds_many :tags, as: :taggable, class_name: "PublicTag"
  
  has_many :user_tags, as: :taggable

  # telling Mongoid::History how you want to track changes
  track_history   modifier_field: :modifier, # adds "referenced_in :modifier" to track who made the change, default is :modifier
                  version_field: :version,   # adds "field :version, type:  Integer" to track current version, default is :version
                  track_create:  true,    # track document creation, default is false
                  track_update:  true,     # track document updates, default is true
                  track_destroy:  true     # track document destruction, default is false

  def set_name
    unless self.surname.blank?
      unless self.given_name.blank?
        self.name = self.surname + ", " + self.given_name
      else
        self.name = self.surname
      end
    else 
      if ![nil,""].include?( self.given_name )
        self.name = self.given_name
      end
    end
  end
  
  def searchref
  end

  def release_title
    self.release_wiki_link.title 
  end

  def release_title=(value)
    self.release_wiki_link.title = value
  end

  def work_wiki_links_text
    work_wiki_links.collect{|v| v.reference_text }.join("||")
  end

  def work_wiki_links_combined_links
    work_wiki_links.collect{|v| v.combined_link }
  end

  def work_wiki_links_text=(value)
    links = []
    value.split("||").uniq.each{|q| 
      links << ArtistWorkWikiLink.new(reference_text: q.strip)
    }
    self.work_wiki_links = links
  end

  def release_wiki_links_text
    release_wiki_links.collect{|v| v.reference_text }.join("||")
  end

  def release_wiki_links_combined_links
    release_wiki_links.collect{|v| v.combined_link }
  end

  def release_wiki_links_text=(value)
    links = []
    value.split("||").uniq.each{|q| 
      links << ArtistReleaseWikiLink.new(reference_text: q.strip) 
    }
    self.release_wiki_links = links
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
    value.split("||").uniq.each{|q| 
      links << ArtistRecordingWikiLink.new(reference_text: q.strip) 
    }
    self.recording_wiki_links = links   
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
      links << ArtistArtistWikiLink.new(reference_text: q.strip) 
    }
    self.artist_wiki_links = links  
  end

  def add_supplementary_section
    self.supplementary_sections << SupplementarySection.new()
  end

  scope :queried, ->(q) {
    current_query = all
    asq = ArtistWikiLink.search_query(q)
    asq.filled_query_fields.each {|field|
      case field
        when :oid
          current_query = current_query.where(:_id=>asq[field])
        when :name
          current_query = current_query.csearch(asq[field], match: :all)
        when :surname, :given_name, :birth_location, :death_location
          current_query = current_query.where(field=>/#{Regexp.quote(asq[field].downcase)}/i)
        when :birth_date, :death_date, :created_at, :updated_at
          current_query = current_query.where(field=>asq[field])        
      end 
    }
    current_query
  }

  def grouped_work_wiki_links
    GroupedWikiLink.new(ArtistWorkWikiLink, self.work_wiki_links).groups
  end

  def normalized_name
    self.name.to_s.
      mb_chars.
      normalize(:kd).
      to_s.
      gsub(/[._:;'"`,?|+={}()!@#%^&*<>~\$\-\\\/\[\]\s+]/, ''). # strip punctuation
      gsub(/[^[:alnum:]\s]/,'').   # strip accents
      downcase.strip
  end

  def name_first_letter
    first_letter = self.normalized_name[0] || ""
    first_letter = "#" if ("0".."9").include?(first_letter)
    first_letter
  end

  def update_cached_fields
    self.set_name
    self.cache_normalized_name = self.normalized_name
    self.cache_first_letter = self.name_first_letter
    self.signature = self.to_search_query.signature
  end

  def to_wiki_link(klass=ArtistWikiLink, attributes={})
    #attributes.merge!({reference_text: self.to_search_query.q, artist: self})
    attributes.merge!({reference_text: self.to_search_query.q})
    klass.new(attributes)
  end
  
  def to_search_query
    sq = ArtistWikiLink::SearchQuery.new
    ArtistWikiLink::SearchQuery::QUERY_ATTRS.keys.each {|key|
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

  scope :born_during_month_of, ->(month) {
    self.where(birth_date: /.*\-#{"%02d"%(month)}\-.*/)
  }
  #Artist.born_during_month_of(04).all.group_by {|a| a.birth_date.year }.each {|a| puts  "* [" + a[0].to_s + "] - "+ a[1].collect{|b| "["+ b.name + "]"}.join(", ")}

  scope :died_during_month_of, ->(month) {
    self.where(death_date: /.*\-#{"%02d"%(month)}\-.*/)
  }
  #Artist.died_during_month_of(04).all.group_by {|a| a.death_date.year }.each {|a| puts  "* [" + a[0].to_s + "] - "+ a[1].collect{|b| "["+ b.name + "]"}.join(", ")}

  #Artist.all.group_by {|a| a.name[0].upcase }.sort{|a, b| a[0] <=> b[0]}.each {|a| puts "* ["+ a[0] + "] - " + a[1][0..4].collect{|b| "[" + b.name + "]"}.join(", ") + (a[1][5] ? ", [...]": "") }; nil
  after_destroy do |doc|
    attrs = "" 
    ArtistWikiLink::SearchQuery::QUERY_ATTRS.keys.each {|attri| attrs += "#{attri}: \"#{doc.send(attri)}\" "}
    [Artist, Recording, Release, Work].each do |klass|
      klass.where("artist_wiki_links.artist_id" => doc.id).all.each do |rec|
        rec.artist_wiki_links.each do |artist|
          if artist.artist_id == doc.id
            artist.artist_id = nil
            artist.reference_text = attrs
            artist.save!
          end
        end
      end
    end
  end
  before_save do |doc|
    doc.missing_supplementary_sections = doc.supplementary_sections.length == 0
    true
  end
  
end
