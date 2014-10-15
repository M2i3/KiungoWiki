class UserTag
  include Mongoid::Document
  
  belongs_to :user
  belongs_to :taggable, polymorphic: true
  field :name, type: String
  field :cache_normalized_name, type: String, default: ''
  index({ cache_normalized_name: 1 }, { background: true })
  [:user, :name].each do |field|
    validates_presence_of field
  end
  
  after_create do |doc|
    # if no tag is present that is relevent
    if doc.taggable.tags.where(name: /#{doc.name}/i).size == 0
      count = ENV["TAG_COUNT"].to_i # environment set tag count
      # if there is other tags like this that equal this
      if doc.taggable.user_tags.where(name: /#{doc.name}/i).size == (count - 1)
        doc.taggable.tags << PublicTag.new(name: doc.name, size: count) # create and add a new tag
        doc.taggable.save! # save the taggable
      end
    else
      tag = doc.taggable.tags.where(name: /#{doc.name}/i).first # grab first relevant tag
      tag.inc(:size, 1) # increment the count
    end
  end
  
  before_destroy do |doc|
    # if no tag is present that is relevent
    if doc.taggable.tags.where(name: /#{doc.name}/i).size != 0
      count = ENV["TAG_COUNT"].to_i # environment set tag count
      # if there is other tags like this that equal this
      tag = doc.taggable.user_tags.where(name: /#{doc.name}/i).first
      if doc.taggable.user_tags.where(name: /#{doc.name}/i).size == (count - 1)
        tag.destroy! # destroy the tag
      else
        tag.dec(:size, 1) # decrement the count
      end
    end
  end

  before_save do |doc|
    doc.cache_normalized_name = doc.normalized_name
  end

  def normalized_name
    self.name.to_s.
      mb_chars.
      normalize(:kd).
      to_s.
      gsub(/[._:;'"`,?|+={}()!@#%^&*<>~\$\-\\\/\[\]\s+]/, ''). # strip punctuation
      gsub(/[^[:alnum:]\s]/,'').   # strip accents
      downcase.strip
  end
end
