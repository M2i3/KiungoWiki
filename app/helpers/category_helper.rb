module CategoryHelper
  def category_of_the_month
    Category.first
  end

  def multi_purpose_category_index_title(params)
    title = Category.model_name.human.pluralize 
    if params[:recent_changes]
      title += " modifiees recemment"
    end
    title
  end

  def alpha_category_links
    alphabetic_category_grouping.collect{|cat|
      link_to heading, alphabetic_categories_path(:letter=>cat)
    }.join(", ").html_safe
  end

  def alphabetic_category_grouping
    grouping = {}

    Category.all.entries {|cat|
      grouping[cat] = cat
    }
    grouping
  end

end
