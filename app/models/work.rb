class Work
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Search
  include Mongoid::History::Trackable

  #
  # basic entity information
  #
  field :title, :type => String, :default => ""
  field :date_written, :type => IncDate
  field :copyright, :type => String
  field :language_code, :type => String
  field :publisher, :type => String
  field :lyrics, :type => String
  field :chords, :type => String
  field :origworkid, :type => String
  field :is_lyrics_verified, :type => Integer
  field :is_credits_verified, :type => Integer
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

  validates_presence_of :title

  embeds_many :artist_wiki_links, :as=>:linkable
  validates_associated :artist_wiki_links
  accepts_nested_attributes_for :artist_wiki_links

  embeds_many :recording_wiki_links, :as=>:linkable
  accepts_nested_attributes_for :recording_wiki_links
  validates_associated :recording_wiki_links

  embeds_many :work_wiki_links, :as=>:linkable
  accepts_nested_attributes_for :work_wiki_links
  validates_associated :work_wiki_links

  # telling Mongoid::History how you want to track changes
  track_history   :modifier_field => :modifier, # adds "referenced_in :modifier" to track who made the change, default is :modifier
                  :version_field => :version,   # adds "field :version, :type => Integer" to track current version, default is :version
                  :track_create   =>  true,    # track document creation, default is false
                  :track_update   =>  true,     # track document updates, default is true
                  :track_destroy  =>  true     # track document destruction, default is false


  def artist_wiki_links_text
    artist_wiki_links.collect{|v| v.reference_text }.join(",")
  end

  def artist_wiki_links_combined_links
    artist_wiki_links.collect{|v| v.combined_link }
  end

  def artist_wiki_links_text=(value)
    #puts "******************* handling new value #{value}"
    self.artist_wiki_links.reverse.each{|a| a.destroy} #TODO find a way to do it at large since the self.artist_wiki_links.clear does not work

    #puts "there are now #{self.artist_wiki_links.size}"
    value.split(",").each{|q| 
      self.artist_wiki_links.build(:reference_text=>q.strip) 
    }    
    #puts "there are now #{self.artist_wiki_links.size}"
    #puts "parent changed?? #{self.changed?}"
  end

  def recording_wiki_links_text
    recording_wiki_links.collect{|v| v.reference_text }.join(",")
  end

  def recording_wiki_links_combined_links
    recording_wiki_links.collect{|v| v.combined_link }
  end

  def recording_wiki_links_text=(value)
    self.recording_wiki_links.each{|a| a.destroy} #TODO find a way to do it at large since the self.artist_wiki_links.clear does not work
    value.split(",").each{|q| 
      self.recording_wiki_links.build(:reference_text=>q.strip) 
    }    
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
      self.work_wiki_links.build(:reference_text=>q.strip) 
    }    
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
    self.cache_normalized_title = self.normalized_title
    self.cache_first_letter = self.title_first_letter
  end

  scope :queried, ->(q) {
    current_query = all
    wsq = WorkSearchQuery.new(q)
    wsq.filled_query_fields.each {|field|
      case field
        when :title
          current_query = current_query.csearch(wsq[field])
        when :publisher, :copyright, :language_code, :lyrics, :info
          current_query = current_query.where(field=>/#{wsq[field].downcase}/i)
        when :date_written, :created_at, :updated_at
          current_query = current_query.where(field=>wsq[field])        
      end 
    }
    current_query
  }

  #Work.all.group_by {|a| a.title_first_letter.upcase }.sort{|a, b| a <=> b}.each {|a| puts "* [" + a[0] + "] - " + a[1][0..4].collect{|b| "[" + b.title + "]"}.join(", ") + (a[1][5] ? ", [...]": "") }; nil
end


