module RecordingsHelper
  def recording_of_the_month
    Recording.first
  end

  def multi_purpose_recording_index_title(params)
    title = Recording.model_name.human.pluralize 
    if params[:recent_changes]
      title += " modifiees recemment"
    end
    title
  end

  def alpha_recording_links
    alphabetic_recording_grouping.collect{|letter, heading|
      link_to heading, alphabetic_recordings_path(:letter=>letter)
    }.join(", ").html_safe
  end

  def alphabetic_recording_grouping
    grouping = {"#"=>"0..9"}

    ("a".."z").each {|letter|
      grouping[letter] = letter.upcase
    }
    grouping
  end
end
