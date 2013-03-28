class Possession
  include Mongoid::Document
  
  belongs_to :owner, class_name: "User", index: true
  belongs_to :album, index: true
  validates_uniqueness_of :album, scope: :owner
  [:owner, :album].each {|field| validates_presence_of field }
  field :labels, type: Array
  
  after_save do |doc|
    doc.labels.each { |label| Label.find_or_create_by(name:label,user:doc.owner)}
  end
  
  def tokenized_labels
    tokenized = []
    self.labels.each {|label| tokenized << {id:label, name:label}}
    tokenized.to_json
  end
end
