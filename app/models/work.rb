class Work
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning

  field :title, :type => String
  field :date_written, :type => IncDate
  field :copyright, :type => String
  field :language, :type => String
  field :publisher, :type => String
  field :lyrics, :type => String
  field :chords, :type => String

  validates_presence_of :title
end
