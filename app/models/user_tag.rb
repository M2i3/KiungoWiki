class UserTag
  include Mongoid::Document
  
  belongs_to :user
  belongs_to :taggable, polymorphic: true
  field :name, type: String
  [:user, :name].each do |field|
    validates_presence_of field
  end
  
  def taggable
    self.taggable_class.constantize.find self.taggable_id
  end
end