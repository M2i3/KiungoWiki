class Possession
  include Mongoid::Document
  
  belongs_to :owner, class_name: "User", index: true
  belongs_to :album, index: true
  validates_uniqueness_of :album, scope: :owner
end
