class Album
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning

  field :title, :type => String
  field :date_released, :type => IncDate
  field :label, :type => String
  field :media_type, :type => String
  field :reference_code, :type => String
  field :origalbumid, :type => String

  validates_presence_of :title

  scope :queried, ->(q) {
    current_query = all
    asq = AlbumSearchQuery.new(q)
    asq.filled_query_fields.each {|field|
      case field
        when :title, :label, :media_type, :reference_code
          current_query = current_query.where(field=>/#{asq[field].downcase}/i)
        when :date_released, :created_at, :updated_at
          current_query = current_query.where(field=>asq[field])        
      end 
    }
    current_query
  }
end
