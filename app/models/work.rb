class Work
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning

  field :title, :type => String
  field :date_written, :type => IncDate
  field :copyright, :type => String
  field :language_code, :type => String
  field :publisher, :type => String
  field :lyrics, :type => String
  field :chords, :type => String
  field :origworkid, :type => String

  validates_presence_of :title

  embeds_many :artist_wiki_links
  accepts_nested_attributes_for :artist_wiki_links
  validates_associated :artist_wiki_links

  def artist_wiki_links_text
    artist_wiki_links.collect{|v| v.reference_text }.join(",")
  end

  def artist_wiki_links_combined_links
    artist_wiki_links.collect{|v| v.combined_link }
  end

  def artist_wiki_links_text=(value)
    self.artist_wiki_links.each{|a| a.destroy} #TODO find a way to do it at large since the self.artist_wiki_links.clear does not work
    value.split(",").each{|q| 
      self.artist_wiki_links.build(:reference_text=>q.strip) 
    }    
  end

  def language_name
    unless[nil].include?(Language.where(:language_code=>self.language_code).first); 
                Language.where(:language_code=>self.language_code).first[:language_name_french]; 
    end
  end

  scope :queried, ->(q) {
    current_query = all
    wsq = WorkSearchQuery.new(q)
    wsq.filled_query_fields.each {|field|
      case field
        when :title, :publisher, :copyright, :language_code, :lyrics
          current_query = current_query.where(field=>/#{wsq[field].downcase}/i)
        when :date_written, :created_at, :updated_at
          current_query = current_query.where(field=>wsq[field])        
      end 
    }
    current_query
  }
end
