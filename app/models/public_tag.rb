class PublicTag
  include Mongoid::Document
  
  field :size, type: Integer
  field :name, type: String
  
  [:size, :name].each do |field|
    validates_presence_of field
  end
  embedded_in :taggable, polymorphic: true
end