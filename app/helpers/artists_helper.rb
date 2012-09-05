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

  def artist_of_the_month
    Artist.first
  end

  def multi_purpose_artist_index_title(params)
    title = Artist.model_name.human.pluralize 
    if params[:recent_changes]
      title += " modifiees recemment"
    end
    title
  end

  def alpha_artist_links
    alphabetic_artist_grouping.collect{|letter, heading|
      link_to heading, alphabetic_artists_path(:letter=>letter)
    }.join(", ").html_safe
  end

  def alphabetic_artist_grouping
    grouping = {"#"=>"0..9"}

    ("a".."z").each {|letter|
      grouping[letter] = letter.upcase
    }
    grouping
  end
end
