class Artist 
  include Mongoid::Document
  include Mongoid::Timestamps
#TODO: Re-enable some form of versioning most likely using https://github.com/aq1018/mongoid-history instead of the Mongoid::Versioning module
  #after_initialize :set_defaults

  field :name, :type => String
  field :birth_date, :type => IncDate
  field :birth_location, :type => String
  field :death_date, :type => IncDate
  field :death_location, :type => String
  field :origartistid, :type => String

  validates_presence_of :name

  embeds_many :work_wiki_links
  validates_associated :work_wiki_links
  accepts_nested_attributes_for :work_wiki_links

  embeds_many :album_wiki_links
  accepts_nested_attributes_for :album_wiki_links
  validates_associated :album_wiki_links

  def works
    []
  end
  
  def albums
    []
  end

  def work_title
    self.work_wiki_link.title 
  end
  def work_title=(value)
    self.work_wiki_link.title = value
  end
  
  def album_title
    self.album_wiki_link.title 
  end

  def album_title=(value)
    self.album_wiki_link.title = value
  end

  def work_wiki_links_text
    work_wiki_links.collect{|v| v.reference_text }.join(",")
  end

  def work_wiki_links_combined_links
    work_wiki_links.collect{|v| v.combined_link }
  end

  def album_wiki_links_text
    album_wiki_links.collect{|v| v.reference_text }.join(",")
  end

  def album_wiki_links_combined_links
    album_wiki_links.collect{|v| v.combined_link }
  end

  def work_wiki_links_text=(value)
    self.work_wiki_links.each{|a| a.destroy} #TODO find a way to do it at large since the self.work_wiki_links.clear does not work
    value.split(",").each{|q| 
      self.work_wiki_links.build(:reference_text=>q.strip) 
    }    
  end

  def album_wiki_links_text=(value)
    self.album_wiki_links.each{|a| a.destroy} #TODO find a way to do it at large since the self.album_wiki_links.clear does not work
    value.split(",").each{|q| 
      self.album_wiki_links.build(:reference_text=>q.strip) 
    }    
  end

  scope :queried, ->(q) {
    current_query = all
    asq = ArtistSearchQuery.new(q)
    asq.filled_query_fields.each {|field|
      case field
        when :name, :birth_location, :death_location
          current_query = current_query.where(field=>/#{asq[field].downcase}/i)
        when :birth_death, :death_date, :created_at, :updated_at
          current_query = current_query.where(field=>asq[field])        
      end 
    }
    current_query
  }

  private 
  def set_defaults
  end
end
