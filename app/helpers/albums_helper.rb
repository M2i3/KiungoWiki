module AlbumsHelper
  def album_of_the_month
    Album.first
  end

  def multi_purpose_album_index_title(params)
    title = Album.model_name.human.pluralize 
    if params[:recent_changes]
      title += " modifiees recemment"
    end
    title
  end

  def alpha_album_links
    alphabetic_album_grouping.collect{|letter, heading|
      link_to heading, alphabetic_albums_path(:letter=>letter)
    }.join(", ").html_safe
  end

  def alphabetic_album_grouping
    grouping = {"#"=>"0..9"}

    ("a".."z").each {|letter|
      grouping[letter] = letter.upcase
    }
    grouping
  end
end
