class Recording 
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search
  include Mongoid::History::Trackable

#TODO: Re-enable some form of versioning most likely using https://github.com/aq1018/mongoid-history instead of the Mongoid::Versioning module
  field :title, :type => String
  field :recording_date, :type => IncDate
  field :recording_location, :type => String
  field :duration, :type => Duration
  field :rythm, :type => Integer
  field :origrecordingid, :type => String
  field :info, :type => String, :default => ""

  #
  # calculated values so we can index and sort
  #
  field :cache_normalized_title, :type => String, :default => ""
  field :cache_first_letter, :type => String, :default => ""

  before_save :update_cached_fields

  index({ cache_normalized_title: 1 }, { background: true })
  index({ cache_first_letter: 1, cache_normalized_title: 1 }, { background: true })

  search_in :title, {:match => :all}
  
  validates_presence_of :work_wiki_link
#  validates_length_of :work_title, :in=>1..500, :allow_nil=>true
#  validates_numericality_of :duration, :greater_than=>0, :allow_nil=>true  
#  validates_format_of :recording_date_text, :with=>/^(\d{4})(?:-?(\d{0,2})(?:-?(\d{0,2}))?)?$/, :allow_nil=>true
  validates_numericality_of :rythm, :greater_than=>0, :allow_nil=>true

  embeds_one :work_wiki_link, :as=>:linkable, :class_name=>"RecordingWorkWikiLink"
  validates_associated :work_wiki_link  
  accepts_nested_attributes_for :work_wiki_link

  embeds_many :artist_wiki_links, :as=>:linkable, :class_name=>"RecordingArtistWikiLink"
  accepts_nested_attributes_for :artist_wiki_links
  validates_associated :artist_wiki_links

  embeds_many :album_wiki_links, :as=>:linkable, :class_name=>"RecordingAlbumWikiLink"
  accepts_nested_attributes_for :album_wiki_links
  validates_associated :album_wiki_links

  embeds_many :category_wiki_links, :as=>:linkable
  accepts_nested_attributes_for :category_wiki_links
  validates_associated :category_wiki_links

  # telling Mongoid::History how you want to track changes
  track_history   :modifier_field => :modifier, # adds "referenced_in :modifier" to track who made the change, default is :modifier
                  :version_field => :version,   # adds "field :version, :type => Integer" to track current version, default is :version
                  :track_create   =>  true,    # track document creation, default is false
                  :track_update   =>  true,     # track document updates, default is true
                  :track_destroy  =>  true     # track document destruction, default is false



  def album_title
    self.album_wiki_link.title 
  end

  def work_wiki_link_text
    (work_wiki_link && work_wiki_link.reference_text) || ""
  end

  def work_wiki_link_combined_link
    work_wiki_link && [work_wiki_link.combined_link]
  end

  def work_wiki_link_text=(value)
    self.work_wiki_link = WorkWikiLink.new({:reference_text=>value})
  end

  def artist_wiki_links_text
    artist_wiki_links.collect{|v| v.reference_text }.join(",")
  end

  def artist_wiki_links_combined_links
    artist_wiki_links.collect{|v| v.combined_link }
  end

  def artist_wiki_links_text=(value)
    self.artist_wiki_links.reverse.each{|a| a.destroy} #TODO find a way to do it at large since the self.artist_wiki_links.clear does not work
    value.split(",").each{|q| 
      self.artist_wiki_links.build(:reference_text=>q.strip) 
    }    
  end

  def first_artist_object_text
    self.artist_wiki_links.first && self.artist_wiki_links.first.name(true)
  end

  def album_wiki_links_text
    album_wiki_links.collect{|v| v.reference_text }.join(",")
  end

  def album_wiki_links_combined_links
    album_wiki_links.collect{|v| v.combined_link }
  end

  def album_wiki_links_text=(value)
    self.album_wiki_links.reverse.each{|a| a.destroy} #TODO find a way to do it at large since the self.album_wiki_links.clear does not work
    value.split(",").each{|q| 
      self.album_wiki_links.build(:reference_text=>q.strip) 
    }    
  end

  def category_wiki_links_text
    category_wiki_links.collect{|v| v.reference_text }.join(",")
  end

  def category_wiki_links_combined_links
    category_wiki_links.collect{|v| v.combined_link }
  end

  def category_wiki_links_text=(value)
    self.category_wiki_links.reverse.each{|a| a.destroy} #TODO find a way to do it at large since the self.album_wiki_links.clear does not work
    value.split(",").each{|q| 
      self.category_wiki_links.build(:reference_text=>q.strip) 
    }    
  end

  def category_name
    unless["0","",nil].include?(self.category_wiki_links)
      self.category_wiki_links.collect{|v| v.category_name}.join(', ')
    else
      "unknown"
    end
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
    self[:title] = self.work_wiki_link.object_text 
    self.cache_normalized_title = self.normalized_title
    self.cache_first_letter = self.title_first_letter
  end

  def to_wiki_link
    RecordingWikiLink.new(:reference_text=>"oid:#{self.id}", :recording=>self)
  end

  scope :queried, ->(q) {
    current_query = all
    rsq = RecordingWikiLink.search_query(q)
    rsq.filled_query_fields.each {|field|
      case field
        when :title
          current_query = current_query.csearch(rsq[field])
        when :info, :category_name
          current_query = current_query.where(field=>/#{rsq[field].downcase}/i)
        when :created_at, :duration, :recording_date, :rythm, :update_at
          current_query = current_query.where(field=>rsq[field])        
      end 
    }
    current_query
  }

end
