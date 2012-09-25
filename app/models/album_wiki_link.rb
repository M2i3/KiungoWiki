class AlbumWikiLink < WikiLink
  include Mongoid::Document

  set_reference_class Album
  cache_attributes :title, :label, :date_released, :reference_code, :media_type

  def title_with_objectq
    title_without_objectq.blank? ? self.objectq : title_without_objectq
  end
  alias_method_chain :title, :objectq

  def object_text
    GroupText.new([
        self.title.to_s,
        GroupText.new([
            GroupText.new([
                 self.date_released], 
                 :before_text=>"(", :after_text=>")"), 
            self.album && self.album.first_artist_display_text],
            :sep=>" - ")],
        :sep=>" - ").to_s
  end

  class SearchQuery < ::SearchQuery 
    def self.query_expressions
      superclass.query_expressions.merge({ title: :text,
        media_type: :text,
        date_released: :date,
        label: :text,
        reference_code: :text, 
        info: :text
      })
    end
    def self.catch_all
      "title"
    end 
  end

end

