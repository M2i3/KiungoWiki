class Change
  include Mongoid::History::Tracker
  include Mongoid::Timestamps

  index({ scope: 1, _id: 1 }, { background: true })
  index({ scope: 1, association_chain: 1 }, { background: true })


  def display_text
    wiki_link.display_text
  end

  def modifier_display_text
    self.modifier ? self.modifier.nickname : "Kiungowiki"
  end

  def change_date
    self.id.generation_time
  end

  def change_type 
    self.version == 1 ? :created : :updated
  end

  def change_type_text
    self.change_type  
    I18n.t("mongoid.attributes.change.change_type_text.#{self.change_type}")
  end

  def wiki_link
    self.trackable.to_wiki_link
  end

end
