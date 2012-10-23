class CollectionItem
  include Mongoid::Document

  belongs_to :owner, :class_name=>"User"
  embeds_one :owned_wiki_link, as: :collected, class_name:"Link"

  field :acquisition_date, :type => Date, :default => lambda {DateTime.now}
  field :rating, :type=>Integer, :default=>0

  field :labels, :type=>Array, :default=>[]

  field :notes, :type=>String

  def title
    (owned_wiki_link && owned_wiki_link.display_text) || "???"    
  end

  def owned_wiki_link_text
    (owned_wiki_link && owned_wiki_link.reference_text) || ""
  end

  def owned_wiki_link_combined_links
    [owned_wiki_link && owned_wiki_link.combined_link]
  end

  def owned_wiki_link_text=(value)
    self.owned_wiki_link = AlbumWikiLink.new(:reference_text=>value)
  end

  def labels_text
    labels.join("; ")
  end

  def labels_text=(value)
    puts "updating labels with value #{value}"
    labels = value.split(";").collect{|v| v.strip}
  end
end
