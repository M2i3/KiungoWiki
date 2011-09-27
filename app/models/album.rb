class Album
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning

  field :title, :type => String
  field :date_released, :type => IncDate
  field :label, :type => String
  field :media_type, :type => String
  field :reference_code, :type => String

  validates_presence_of :title

  scope :queried, ->(q) {
    current_query = all
    wsq = AlbumSearchQuery.new(q)
    wsq.filled_query_fields.each {|field|
      case field
        when :title, :label, :media_type, :reference_code
          current_query = current_query.where(field=>/#{wsq[field].downcase}/i)
        when :date_released
          current_query = current_query.where(field=>wsq[field])        
      end 
    }
    current_query
  }
end