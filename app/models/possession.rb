class Possession
  include Mongoid::Document
  
  belongs_to :owner, class_name: "User", index: true
  belongs_to :album, index: true
end
