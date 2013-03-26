class Label
  include Mongoid::Document
  
  belongs_to :user, index: true
  belongs_to :possession
  validates_presence_of :name
end
