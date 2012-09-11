class RecordingWikiLink < WikiLink
  include Mongoid::Document

  set_reference_class Recording, SearchQuery
  cache_attributes :title, :recording_date, :duration 

  def title_with_objectq
    title_without_objectq.blank? ? self.objectq : title_without_objectq
  end
  alias_method_chain :title, :objectq

  def trackNb
    searchref[:trackNb]
  end

  def itemId
    searchref[:itemId]
  end

  def itemSection
    searchref[:itemSection]
  end

  def title
    (recording && self.recording.title) || self.objectq
  end
  
  def duration
    (self.recording && self.recording.duration) || ""
  end

  def recording_date
    (self.recording && self.recording.recording_date) || ""
  end

  def object_text
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
    def self.query_expressions
      superclass.query_expressions.merge({ 
        title: :text,
        category_name: :text,
        recording_date: :date,
        duration: :duration,
        recording_location:  :text,
        rythm: :word,
        trackNb: :numeric,
        itemId: :word,
        itemSection: :character,
        info: :text
      })
    end
    def self.catch_all
      "title"
    end 
    def self.meta_fields
      super + [:trackNb, :itemId, :itemSection]
    end
  end
end

