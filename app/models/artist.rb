class Artist 
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning
  include Mongoid::Search

#TODO: Re-enable some form of versioning most likely using https://github.com/aq1018/mongoid-history instead of the Mongoid::Versioning module

  field :name, :type => String
  field :surname, :type => String, :default => ""
  field :given_name, :type => String, :default => ""
  field :birth_date, :type => IncDate
  field :birth_location, :type => String
  field :death_date, :type => IncDate
  field :death_location, :type => String
  field :origartistid, :type => String
  field :is_group, :type => Integer
  field :info, :type => String, :default => ""

  #
  # calculated values so we can index and sort
  #
  field :cache_normalized_name, :type => String, :default => ""
  field :cache_first_letter, :type => String, :default => ""

  before_save :update_cached_fields

  index({ cache_normalized_name: 1 }, { background: true })
  index({ cache_first_letter: 1, cache_normalized_name: 1 }, { background: true })

  search_in :name, :surname, :given_name, :birth_location, :death_location, {:match => :all}

  validates_presence_of :surname

  embeds_many :work_wiki_links, :as=>:linkable
  validates_associated :work_wiki_links
  accepts_nested_attributes_for :work_wiki_links

  embeds_many :album_wiki_links, :as=>:linkable
  accepts_nested_attributes_for :album_wiki_links
  validates_associated :album_wiki_links

  embeds_many :recording_wiki_links, :as=>:linkable
  accepts_nested_attributes_for :recording_wiki_links
  validates_associated :recording_wiki_links

  embeds_many :artist_wiki_links, :as=>:linkable
  accepts_nested_attributes_for :artist_wiki_links
  validates_associated :artist_wiki_links

  def set_name
    if ![nil,""].include?(self.surname)
      if ![nil,""].include?(self.given_name)
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

  def work_wiki_links_text=(value)
    self.work_wiki_links.reverse.each{|a| a.destroy} #TODO find a way to do it at large since the self.work_wiki_links.clear does not work
    value.split(",").uniq.each{|q| 
      #puts "nb wwk bef = " + self.work_wiki_links.count.to_s
      self.work_wiki_links.build(:reference_text=>q.strip) 
      #puts "nb wwk aft= " + self.work_wiki_links.count.to_s
    }    
  end

  def album_wiki_links_text
    album_wiki_links.collect{|v| v.reference_text }.join(",")
  end

  def album_wiki_links_combined_links
    album_wiki_links.collect{|v| v.combined_link }
  end

  def album_wiki_links_text=(value)
    self.album_wiki_links.reverse.each{|a| a.destroy} #TODO find a way to do it at large since the self.album_wiki_links.clear does not work
    value.split(",").uniq.each{|q| 
      self.album_wiki_links.build(:reference_text=>q.strip) 
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
    self.recording_wiki_links.each{|a| a.destroy} #TODO find a way to do it at large since the self.recording_wiki_links.clear does not work
    value.split(",").uniq.each{|q| 
      self.recording_wiki_links.build(:reference_text=>q.strip) 
    }    
  end

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
  scope :queried, ->(q) {
    current_query = all
    asq = ArtistSearchQuery.new(q)
    asq.filled_query_fields.each {|field|
      case field
        when :name
          current_query = current_query.csearch(asq[field])
        when :surname, :given_name, :birth_location, :death_location, :info
          current_query = current_query.where(field=>/#{asq[field].downcase}/i)
        when :birth_date, :death_date, :created_at, :updated_at
          current_query = current_query.where(field=>asq[field])        
      end 
    }
    current_query
  }

  def grouped_work_wiki_links
    GroupedWikiLink.new(WorkWikiLink, self.work_wiki_links).groups
  end

  def normalized_name
    self.name.to_s.
      mb_chars.
      normalize(:kd).
      to_s.
      gsub(/[._:;'"`,?|+={}()!@#%^&*<>~\$\-\\\/\[\]]/, ' '). # strip punctuation
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
  end

  scope :born_during_month_of, ->(month) {
    self.where(:birth_date=>/.*\-#{"%02d"%(month)}\-.*/)
  }
  #Artist.born_during_month_of(04).all.group_by {|a| a.birth_date.year }.each {|a| puts  "* [" + a[0].to_s + "] - "+ a[1].collect{|b| "["+ b.name + "]"}.join(", ")}

  scope :died_during_month_of, ->(month) {
    self.where(:death_date=>/.*\-#{"%02d"%(month)}\-.*/)
  }
  #Artist.died_during_month_of(04).all.group_by {|a| a.death_date.year }.each {|a| puts  "* [" + a[0].to_s + "] - "+ a[1].collect{|b| "["+ b.name + "]"}.join(", ")}

  #Artist.all.group_by {|a| a.name[0].upcase }.sort{|a, b| a[0] <=> b[0]}.each {|a| puts "* ["+ a[0] + "] - " + a[1][0..4].collect{|b| "[" + b.name + "]"}.join(", ") + (a[1][5] ? ", [...]": "") }; nil
  
end
