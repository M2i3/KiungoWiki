class Publisher
  include Mongoid::Document
  
  field :name, type: String
  validates_presence_of :name
  field :count, type: Integer, default: 0
end