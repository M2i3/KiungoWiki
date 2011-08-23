class Work
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning

  field :title
end
