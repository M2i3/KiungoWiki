class Change
  include Mongoid::History::Tracker
  include Mongoid::Timestamps

  index({ scope: 1, _id: 1 }, { background: true })
  index({ scope: 1, association_chain: 1 }, { background: true })


  def display_text
    if wiki_link
      wiki_link.display_text
    else
      "Unknown"
    end
  end

  def modifier_display_text
    self.modifier ? self.modifier.nickname : "Kiungowiki"
  end

  def change_date
    self.id.generation_time
  end

  def created_at_text
    self.created_at ? I18n.l(self.created_at, :format=>:default) : ""
  end

  def change_type 
    self.version == 1 ? :created : :updated
  end

  def change_type_text
    self.change_type  
    I18n.t("mongoid.attributes.change.change_type_text.#{self.change_type}")
  end

  def wiki_link
    if self.trackable
      self.trackable.to_wiki_link
    else
      nil
    end
  end

end
