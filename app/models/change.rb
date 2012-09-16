class Change
  include Mongoid::History::Tracker

#  field :author
#  field :comment  
#  field :version, :type => Integer, :default => 1

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
