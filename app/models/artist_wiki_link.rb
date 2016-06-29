class ArtistWikiLink < WikiLink
  include Mongoid::Document

  set_reference_class Artist
  cache_attributes :name, :surname, :given_name, :birth_date, :birth_location

  field :start_date, type: String
  field :end_date, type: String

  class << self
    def signed_as(signature)
      [WorkArtistWikiLink, RecordingArtistWikiLink, ReleaseArtistWikiLink, ArtistArtistWikiLink].collect{|model|
        model.signed_as(signature)
      }.compact.first
    end
  end

  def object_text
    self.name.to_s
  end

  def display_text
    text = [self.name.to_s]

    unless self.birth_date.blank? && self.birth_location.blank?
      birth_text = []
      birth_text << IncDate.new(self.birth_date).year unless self.birth_date.blank?
      birth_text << self.birth_location unless self.birth_location.blank?

      text << "(" + birth_text.join(", ") + ")"
    end

    text.join(" ")
  end

  class SearchQuery < ::SearchQuery
    QUERY_ATTRS = {surname: :text,
            given_name: :text,
            name: :text,
            birth_date: :date,
            birth_location: :text,
            death_date: :date,
            death_location: :text
          }
    def self.query_expressions
      superclass.query_expressions.merge QUERY_ATTRS
    end
    def self.catch_all
      :surname
    end 
    def self.primary_display_text
      [:name]
    end
    def self.hidden_display_text
      [:surname,:given_name]
    end
    def self.canonical_exclusion_fields
      [:name]
    end
  end
end
