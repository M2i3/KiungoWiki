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

  validates_presence_of :title

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
