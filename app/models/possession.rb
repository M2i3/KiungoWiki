class Possession
  include Mongoid::Document
  
  belongs_to :owner, class_name: "User", index: true
  belongs_to :release, index: true
  validates_uniqueness_of :release, scope: :owner
  [:owner, :release].each {|field| validates_presence_of field }
  field :labels, type: Array, default: []
  field :rating, type: Integer, default: 0
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
        Label.where(name:label,user:doc.owner).first_or_create!.inc(:count, 1)
      end
      # deleted labels
      (original.reject{|lab| new_labels.include? lab }).each do |label|
        found = Label.where(name:label,user:doc.owner).first
        found.inc(:count, 1) if found # backwards compatiable
      end
    end
  end

  def labels_text
    self.labels.join(", ")
  end

  def labels_text=(value)
    self.labels.clear
    value.split(",").each{|q| 
      self.labels << q
    }    
  end

  def release_wiki=(wiki_id)
    self.release_id = wiki_id.sub("oid:",'').strip
  end
  
  def release_wiki
    "oid:#{self.release_id}"
  end

  def tokenized_labels
    tokenized = []
    self.labels.each {|label| tokenized << {id:label, name:label}}
    tokenized.to_json
  end
end
