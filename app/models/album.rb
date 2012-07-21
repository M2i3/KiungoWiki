class Album
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include Mongoid::Search

  field :title, :type => String
  field :date_released, :type => IncDate
  field :label, :type => String
  field :media_type, :type => String
  field :reference_code, :type => String
  field :number_of_recordings, :type => Integer
  field :origalbumid, :type => String
  field :info, :type => String, :default => ""

  search_in :title, :label, {:match => :all}

  validates_presence_of :title

  embeds_many :artist_wiki_links, :as=>:linkable
  accepts_nested_attributes_for :artist_wiki_links
  validates_associated :artist_wiki_links

  embeds_many :recording_wiki_links, :as=>:linkable
  accepts_nested_attributes_for :recording_wiki_links
  validates_associated :recording_wiki_links

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
    self.recording_wiki_links.reverse.each{|a| a.destroy} #TODO find a way to do it at large since the self.recording_wiki_links.clear does not work
    value.split(",").each{|q| 
      self.recording_wiki_links.build(:reference_text=>q.strip) 
    }    
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

  
  scope :queried, ->(q) {
    current_query = all
    asq = AlbumSearchQuery.new(q)
    asq.filled_query_fields.each {|field|
      case field
        when :title
          current_query = current_query.csearch(asq[field])
        when :label, :media_type, :reference_code, :info
          current_query = current_query.where(field=>/#{asq[field].downcase}/i)
        when :date_released, :created_at, :updated_at
          current_query = current_query.where(field=>asq[field])        
      end 
    }
    current_query
  }


  #Album.all.group_by {|a| a.title_first_letter.upcase }.sort{|a, b| a <=> b}.each {|a| puts "* [" + a[0] + "] - " + a[1][0..4].collect{|b| "[" + b.title + "]"}.join(", ") + (a[1][5] ? ", [...]": "") }; nil
  #Album.all.group_by {|a| a.date_released.year.to_s }.sort{|a, b| a <=> b}.each {|a| puts "* [" + a[0] + "] - " + a[1][0..4].collect{|b| "[" + b.title + "]"}.join(", ") + (a[1][5] ? ", [...]": "") }; nil
  #Album.all.group_by {|a| a.date_released.year.to_s }.sort{|a, b| a <=> b}.each {|a| puts "" + a[0] + ", " + a[1].length.to_s }; nil
end
