class WorkWikiLink < WikiLink
  include Mongoid::Document

  set_reference_class Work

  wiki_link_field :title, type: String, default: ""
  wiki_link_field :date_written, type: IncDate
  wiki_link_field :copyright, type: String
  wiki_link_field :language_code, type: String
  wiki_link_field :origworkid, type: String
  
  define_subclass_signed_as [:recording_work_wiki_link, :artist_work_wiki_link, :work_work_wiki_link]
  
  def title_with_objectq
    title_without_objectq.blank? ? self.objectq_display_text : title_without_objectq
  end
  alias_method_chain :title, :objectq

  def language_name
    unless["0","",nil].include?(Language.where(:language_code=>self.language_code).first); 
                Language.where(:language_code=>self.language_code).first[:language_name_french]; 
    end
  end

  def object_text
    self.title.to_s
  end

  def display_text
    GroupText.new([
        self.title.to_s,
        GroupText.new([
            GroupText.new([
                self.date_written, self.language_code], 
                :sep=>", ", :before_text=>"(", :after_text=>")"), 
            self.work && self.work.first_artist_object_text],
            :sep=>" - ")],
        :sep=>" ").to_s

  end

  class SearchQuery < ::SearchQuery
    QUERY_ATTRS = { title: :text,
        copyright: :text,
        lyrics: :text,
        date_written: :date,
        language_code:  :word,
        publisher: :text,
        origworkid: :word
      }
    def self.query_expressions
      superclass.query_expressions.merge QUERY_ATTRS
    end
    def self.catch_all
      :title
    end
    def self.primary_display_text
      [:title]
    end
    
  end

end
