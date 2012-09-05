class WorkWikiLink < WikiLink
  include Mongoid::Document

  set_reference_class Work, WorkSearchQuery
  cache_attributes :title, :language_code, :date_written

  accepts_nested_attributes_for :work

  def title_with_objectq
    title_without_objectq.blank? ? self.objectq : title_without_objectq
  end
  alias_method_chain :title, :objectq

  def work_wiki_links
     (self.work && self.work.work_wiki_links) || ""
  end

  def language_name
    unless["0","",nil].include?(Language.where(:language_code=>self.language_code).first); 
                Language.where(:language_code=>self.language_code).first[:language_name_french]; 
    end
  end

  def object_text
    self.title.to_s 
  end

  def relation
    searchref[:relation] || "undetermined"
  end

  def relation_text
    I18n.t("mongoid.attributes.work.nature_text.#{self.relation}")
  end

end
