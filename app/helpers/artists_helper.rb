module ArtistsHelper
  def date_location_formatted(label, date, location)
    unless date.blank? && location.blank?
      content_tag(:dt, label) + content_tag(:dd, [date, location].reject{|v| v.blank?}.join(", "))      
    end
  end
end
