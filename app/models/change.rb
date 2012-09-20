class Change
  include Mongoid::History::Tracker

  index({ scope: 1, _id: 1 }, { background: true })
  index({ scope: 1, association_chain: 1 }, { background: true })


  def display_text
    wiki_link.display_text
  end

  def change_date
    self.id.generation_time
  end

  def change_type 
    self.version == 1 ? :created : :updated
  end

  def wiki_link
    (self.trackable.class.to_s + "WikiLink").constantize.new(:reference_text=>"oid:#{self.trackable.id}")
  end

end
