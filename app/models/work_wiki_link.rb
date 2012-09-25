class WorkWikiLink < WikiLink
  include Mongoid::Document

  set_reference_class Work
  cache_attributes :title, :language_code, :date_written

  def title_with_objectq
    title_without_objectq.blank? ? self.objectq : title_without_objectq
  end
  alias_method_chain :title, :objectq

#  def work_wiki_links
#     (self.work && self.work.work_wiki_links) || ""
#  end

  def language_name
    unless["0","",nil].include?(Language.where(:language_code=>self.language_code).first); 
                Language.where(:language_code=>self.language_code).first[:language_name_french]; 
    end
  end

  def object_text
    text = [self.title.to_s]
    text << "(" + self.date_written + ")" unless self.date_written.blank?
    text.join(" ")
  end

  class SearchQuery < ::SearchQuery 
    def self.query_expressions
      superclass.query_expressions.merge({ title: :text,
        copyright: :text,
        lyrics: :text,
        date_written: :date,
        language_code:  :word,
        publisher: :text,
        info: :text
      })

    end
    def self.catch_all
      "title"
    end
  end

end
