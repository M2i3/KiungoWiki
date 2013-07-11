class Possession
  include Mongoid::Document
  
  belongs_to :owner, class_name: "User", index: true
  [:owner, :release_wiki_link].each {|field| validates_presence_of field }
  field :display_title, type: String
  field :labels, type: Array, default: []
  field :rating, type: Integer, default: 0
  field :acquisition_date, type: Date
  field :comments, type: String
  
  embeds_one :release_wiki_link, as: :linkable, class_name: "ReleaseWikiLink"
  validates_associated :release_wiki_link  
  accepts_nested_attributes_for :release_wiki_link

  before_save do |doc|
    doc.display_title = doc.release_wiki_link.display_text if doc.display_title.blank?
  end
  
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
        found.inc(:count, -1) if found # backwards compatiable
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
  
  def release_wiki_link_text
    (self.release_wiki_link && release_wiki_link.reference_text) || ""
  end
  
  def release_wiki_link_text=(value)
    self.release_wiki_link = ReleaseWikiLink.new({reference_text: value})
  end

  def tokenized_labels
    tokenized = []
    self.labels.each {|label| tokenized << {id:label, name:label}}
    tokenized.to_json
  end
end
