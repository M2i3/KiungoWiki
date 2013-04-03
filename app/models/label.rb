class Label
  include Mongoid::Document
  
  belongs_to :user, index: true
  validates_presence_of :name
  field :count, type: Integer, default: 0
end
