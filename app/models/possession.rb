class Possession
  include Mongoid::Document
  
  belongs_to :owner, class_name: "User", index: true
  belongs_to :album, index: true
  validates_uniqueness_of :album, scope: :owner
  [:owner, :album].each {|field| validates_presence_of field }
  field :labels, type: Array, default: []
  field :rating, type: Integer
  field :acquisition_date, type: Date
  field :comments, type: String
  
  after_save do |doc|
    if doc.changes.has_key? "labels"
      label_changes = doc.changes["labels"]
      original = label_changes[0]
      new_labels = label_changes[1]
      original = [] if original.nil?
      # new labels
      (new_labels.reject{|lab| original.include? lab }).each do |label|
        found = Label.where(name:label,user:doc.owner).first
        if found
          found.count += 1
          found.save!
        else
          Label.create!(name:label,user:doc.owner, count:1)
        end
      end
      # deleted labels
      (original.reject{|lab| new_labels.include? lab }).each do |label|
        found = Label.where(name:label,user:doc.owner).first
        if found # backwards compatiable
          found.count -= 1
          found.save!
        end
      end
    end
  end
  
  def tokenized_labels
    tokenized = []
    self.labels.each {|label| tokenized << {id:label, name:label}}
    tokenized.to_json
  end
end
