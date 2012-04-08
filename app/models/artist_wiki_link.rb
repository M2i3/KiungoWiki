class ArtistWikiLink
  include Mongoid::Document

  field :reference_text
  referenced_in :artist
  embedded_in :linkable, :polymorphic => true

  def reference_text=(value)
    self[:reference_text] = value
    asq = ArtistSearchQuery.new(value)
    if asq[:oid]
      self.artist = Artist.find(asq[:oid]) 
    else
      self.artist = nil
    end
  end

  def searchref
    ArtistSearchQuery.new(self.reference_text)
  end

  def role
    searchref[:role]
  end

  def name
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
      self.reference_text
    end + (role.blank? ? "" : " [#{self.role}]")
  end

  def combined_link
    if self.reference_text || self.name
      {id: self.reference_text, name: self.name.to_s}
    end
  end 

end
