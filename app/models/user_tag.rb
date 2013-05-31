class UserTag
  include Mongoid::Document
  
  belongs_to :user
  belongs_to :taggable, polymorphic: true
  field :name, type: String
  [:user, :name].each do |field|
    validates_presence_of field
  end
  
  def taggable
    self.taggable_type.constantize.find self.taggable_id
  end
  
  after_create do |doc|
    # if no tag is present that is relevent
    if doc.taggable.class.where("tags.name" => /#{doc.name}/i, id:doc.taggable.id).size == 0
      count = ENV["TAG_COUNT"].to_i # environment set tag count
      # if there is other tags like this that equal this
      if UserTag.where(name: /#{doc.name}/i, taggable_type:doc.taggable_type, taggable_id:doc.taggable_id).size == (count - 1)
        doc.taggable.tags << PublicTag.new(name: doc.name, size: count) # create and add a new tag
        doc.taggable.save! # save the taggable
      end
    else
      tag = doc.taggable.class.where("tags.name" => /#{doc.name}/i).first # grab first relevant tag
      tag.size += 1 # increment the count
      tag.save! # save the tag
    end
  end
  
end