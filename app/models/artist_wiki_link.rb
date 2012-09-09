class ArtistWikiLink < WikiLink
  include Mongoid::Document

  set_reference_class Artist, ArtistSearchQuery
  cache_attributes :name, :surname, :given_name, :birth_date, :birth_location


  accepts_nested_attributes_for :artist
  belongs_to :artist, inverse_of: nil

  def role
    searchref[:role]
  end

  def name(exclude_role=false)
    if artist
      case
        when !self.surname.blank? && !self.given_name.blank?
          self.surname + ", " + self.given_name
        when !self.surname.blank?
          self.surname
        when !self.given_name.blank?
          self.given_name
        else
          self.name
      end
    else
      self.objectq
    end + ((role.blank? || exclude_role) ? "" : " [#{self.role}]")
  end

  def object_text
    text = [self.name(true).to_s]

    unless self.birth_date.blank? && self.birth_location.blank?
      birth_text = []
      birth_text << self.birth_date.year unless self.birth_date.blank?
      birth_text << self.birth_location unless self.birth_location.blank?

      text << "(" + birth_text.join(", ") + ")"
    end

    text.join(" ")
  end

  def relation
    searchref[:relation]
  end
end
