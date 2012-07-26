module WorksHelper
  def work_of_the_month
    Work.first
  end

  def multi_purpose_index_title(params)
    title = Work.model_name.human.pluralize 
    if params[:recent_changes]
      title += " modifiees recemment"
    end
    title
  end

  def alpha_links
    alphabetic_grouping.collect{|letter, heading|
      link_to heading, alphabetic_works_path(:letter=>letter)
    }.join(", ").html_safe
  end

  def alphabetic_grouping
    grouping = {"#"=>"0..9"}

    ("a".."z").each {|letter|
      grouping[letter] = letter.upcase
    }
    grouping
  end

end
