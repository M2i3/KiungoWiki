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

  validates_presence_of :name

  def works
    []
  end
  
  def albums
    []
  end

  scope :queried, ->(q) {
    current_query = all
    asq = ArtistSearchQuery.new(q)
    asq.filled_query_fields.each {|field|
      case field
        when :name, :birth_location, :death_location
          current_query = current_query.where(field=>/#{asq[field].downcase}/i)
        when :birth_death, :death_date
          current_query = current_query.where(field=>asq[field])        
      end 
    }
    current_query
  }

  private 
  def set_defaults
  end
end
