module ArtistsHelper
  def date_location_formatted(label, date, location)
    unless date.blank? && location.blank?
      content_tag(:dt, label) + content_tag(:dd, [date, location].reject{|v| v.blank?}.join(", "))      
    end
  end
  
  def updated_or_created_formatted(modified_label, created_label, updated_at, created_at)
  	if updated_at.blank?
  		content_tag(:small, updated_label + " " + updated_at.to_s)
  	else
  		content_tag(:small, created_label + " " + created_at.to_s)
  	end
  end
end
