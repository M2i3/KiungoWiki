class UserTag
  include Mongoid::Document
  
  belongs_to :user
  field :name, type: String
  [:user, :name].each do |field|
    validates_presence_of field
  end
end