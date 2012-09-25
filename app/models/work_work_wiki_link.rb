class WorkWorkWikiLink < WorkWikiLink
  include Mongoid::Document

  def relation
    searchref[:relation] || "undetermined"
  end

  def relation_text
    I18n.t("mongoid.attributes.work.nature_text.#{self.relation}")
  end

  class SearchQuery < self.superclass::SearchQuery 
    def self.query_expressions
      super.merge({ 
        relation: :text
      })
    end
    def self.meta_fields
      super + [:relation]
    end
  end
end


