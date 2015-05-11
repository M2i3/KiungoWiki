class ReleaseWikiLink < WikiLink
  include Mongoid::Document

  set_reference_class Release
  cache_attributes :title, :label, :date_released, :reference_code, :media_type
  field :item_section, type: String
  field :item_id, type: String
  field :track_number, type: String

  def title_with_objectq_display_text
    title_without_objectq_display_text.blank? ? self.objectq_display_text : title_without_objectq_display_text
  end
  alias_method_chain :title, :objectq_display_text

  def object_text
    self.title.to_s
  end

  def display_text
    GroupText.new([
        self.title.to_s,
        GroupText.new([
            GroupText.new([
                 self.date_released], 
                 before_text: "(", after_text: ")"), 
            self.release && self.release.first_artist_display_text],
            sep: " - ")],
        sep: " - ").to_s
  end

  class SearchQuery < ::SearchQuery
    QUERY_ATTRS = { title: :text,
        media_type: :text,
        date_released: :date,
        label: :text,
        reference_code: :text
      }
    def self.query_expressions
      superclass.query_expressions.merge QUERY_ATTRS
    end
    def self.catch_all
      "title"
    end 
    def self.primary_display_text
      [:title]
    end
  end

end

