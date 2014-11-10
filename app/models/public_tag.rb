class PublicTag
  include Mongoid::Document
  
  field :size, type: Integer
  field :name, type: String
  field :cache_normalized_name, type: String, default: ""
  index({ cache_normalized_name: 1 }, { background: true })
  
  [:size, :name].each do |field|
    validates_presence_of field
  end
  embedded_in :taggable, polymorphic: true

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
