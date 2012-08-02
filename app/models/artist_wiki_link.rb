class ArtistWikiLink < WikiLink
  include Mongoid::Document

  set_reference_class Artist, ArtistSearchQuery

  accepts_nested_attributes_for :artist
  belongs_to :artist, inverse_of: nil

  def role
    searchref[:role]
  end

  def name(exclude_role=false)
    if artist
      case
        when !self.artist.surname.blank? && !self.artist.given_name.blank?
          self.artist.surname + ", " + self.artist.given_name
        when !self.artist.surname.blank?
          self.artist.surname
        when !self.artist.given_name.blank?
          self.artist.given_name
        else
          self.artist.name
      end
    else
      self.objectq
    end + ((role.blank? || exclude_role) ? "" : " [#{self.role}]")
  end

  def object_text
    self.name(true).to_s
  end

  def display_text
    object_text + (self.metaq.empty? ? "" : " (#{self.metaq})")
  end
end
