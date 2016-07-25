class RecordingWikiLink < WikiLink
  include Mongoid::Document

  set_reference_class Recording
  
  wiki_link_field :title, type:  String
  wiki_link_field :recording_date, type:  IncDate
  wiki_link_field :recording_location, type:  String
  wiki_link_field :duration, type:  Duration
  wiki_link_field :bpm, type:  Integer

  wiki_link_additional_field :role, type: String
  
  class << self
    def signed_as(signature)
      [WorkRecordingWikiLink, ArtistRecordingWikiLink, ReleaseRecordingWikiLink].collect{|model|
        model.signed_as(signature)
     }.compact.first
    end
  end

  def title_with_objectq
    title_without_objectq.blank? ? self.objectq_display_text : title_without_objectq
  end
  alias_method_chain :title, :objectq

  def object_text
    self.title.to_s
  end

  def display_text
    GroupText.new([
        self.title.to_s,
        GroupText.new([
            GroupText.new([
                self.duration, self.recording_date], 
                :sep=>", ", :before_text=>"(", :after_text=>")"), 
            self.recording && self.recording.first_artist_object_text],
            :sep=>" - ")],
        :sep=>" ").to_s
  end

  class SearchQuery < ::SearchQuery
    QUERY_ATTRS = { 
        title: :text,
        category_name: :text,
        recording_date: :date,
        duration: :duration,
        recording_location:  :text,
        bpm: :word
      }
    def self.query_expressions
      super.merge QUERY_ATTRS
    end
    def self.catch_all
      :title
    end 
    def self.primary_display_text
      [:title]
    end    
  end
end

