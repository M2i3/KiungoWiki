class Category 
  include WikiDocument
  #after_initialize :set_defaults

  field :category_name, type: String
  field :origcategoryid, type: String
  field :info, type: String, default: ""
  field :cache_normalized_name, type: String, default: ''
  
  index({ cache_normalized_name: 1 }, { background: true })

  search_in :category_name, {match: :all}

  validates_presence_of :category_name
  
  scope :queried, ->(q) {
    current_query = all
    asq = CategoryWikiLink.search_query(q)
    asq.filled_query_fields.each {|field|
      case field
        when :oid
          current_query = current_query.where(:_id=>asq[field])        
        when :category_name, :info
          current_query = current_query.where(field=>/#{Regexp.quote(asq[field].downcase)}/i)
      end 
    }
    current_query
  }

  before_save do |doc|
    doc.cache_normalized_name = doc.normalized_name
  end

  def normalized_name
    self.category_name.to_s.
      mb_chars.
      normalize(:kd).
      to_s.
      gsub(/[._:;'"`,?|+={}()!@#%^&*<>~\$\-\\\/\[\]\s+]/, ''). # strip punctuation
      gsub(/[^[:alnum:]\s]/,'').   # strip accents
      downcase.strip
  end
  
  def to_wiki_link(klass=CategoryWikiLink, attributes={})
    attributes.merge!({reference_text: self.to_search_query.q})
    klass.new(attributes)
#    klass.new(reference_text: self.to_search_query.q, recording: self)
  end
    
  def to_search_query
    sq = CategoryWikiLink::SearchQuery.new
    CategoryWikiLink::SearchQuery::QUERY_ATTRS.keys.each {|key|
      sq[key] = self[key]
    }
    sq
  end
  
end
