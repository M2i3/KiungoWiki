class Recording 
  include Mongoid::Document
  include Mongoid::Timestamps
#TODO: Re-enable some form of versioning most likely using https://github.com/aq1018/mongoid-history instead of the Mongoid::Versioning module
  after_initialize :set_defaults

  field :recording_date, :type => IncDate
  field :recording_location, :type => String
  field :duration, :type => Duration
  field :rythm, :type => Integer
  field :sample_rate, :type => Integer
  
#  validates_length_of :work_title, :in=>1..500, :allow_nil=>true
#  validates_numericality_of :duration, :greater_than=>0, :allow_nil=>true  
  validates_numericality_of :rythm, :greater_than=>0, :allow_nil=>true
  validates_numericality_of :sample_rate, :greater_than=>0, :allow_nil=>true

  embeds_one :work_wiki_link
  embeds_one :artist_wiki_link
  embeds_one :album_wiki_link
  accepts_nested_attributes_for :work_wiki_link
  accepts_nested_attributes_for :artist_wiki_link
  accepts_nested_attributes_for :album_wiki_link
  validates_associated :work_wiki_link
  validates_associated :artist_wiki_link
  validates_associated :album_wiki_link

  def work_title
    self.work_wiki_link.title 
  end
  def work_title=(value)
    self.work_wiki_link.title = value
  end

  def title
    self.work_title
  end

  def artist_name
    self.artist_wiki_link.name
  end

  def artist_name=(value)
    self.artist_wiki_link.name = value
  end
  
  def album_title
    self.album_wiki_link.title 
  end

  def album_title=(value)
    self.album_wiki_link.title = value
  end
  
  scope :queried, ->(q) {
    current_query = all
    rsq = RecordingSearchQuery.new(q)
    rsq.filled_query_fields.each {|field|
      case field
        when :title
          current_query = current_query.where(field=>/#{rsq[field].downcase}/i)
        when :created_at, :duration, :recording_date, :rythm, :update_at
          current_query = current_query.where(field=>rsq[field])        
      end 
    }
    current_query
  }

  private 
  def set_defaults
    self.work_wiki_link = WorkWikiLink.new unless self.work_wiki_link
    self.artist_wiki_link = ArtistWikiLink.new unless self.artist_wiki_link
    self.album_wiki_link = AlbumWikiLink.new unless self.album_wiki_link
  end

end
