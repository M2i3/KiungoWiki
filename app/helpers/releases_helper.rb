module ReleasesHelper
  def release_of_the_month
    Release.first
  end

  def multi_purpose_release_index_title(params)
    title = Release.model_name.human.pluralize 
    if params[:recent_changes]
      title += " modifiees recemment"
    end
    title
  end

  def alpha_release_links
    alphabetic_release_grouping.collect{|letter, heading|
      link_to heading, alphabetic_releases_path(letter: letter)
    }.join(", ").html_safe
  end

  def alphabetic_release_grouping
    grouping = {"#"=>"0..9"}

    ("a".."z").each {|letter|
      grouping[letter] = letter.upcase
    }
    grouping
  end
end
