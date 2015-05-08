module SearchHelper
  
  def search_domain_options(selected_domain)
    options = []
    { "all" => I18n.t("headers.all"),
      "artists" => I18n.t("headers.artists_index"),
      "works" => I18n.t("headers.works_index"),
      "recordings" => I18n.t("headers.recordings_index"),
      "releases" => I18n.t("headers.releases_index"),
      "my-music" => I18n.t("headers.possessions_index"),
      "separator-1" => "-",
      "help" => I18n.t("headers.help_index")         
    }.each_pair {|key, heading|
      attrs = {value:key}
      if heading == "-"
        heading = "──────────────"
        attrs[:disabled] = "disabled"
      end
      if selected_domain.to_s == key.to_s
        attrs[:selected] = "selected"
      end
      options << content_tag(:option, heading, attrs)
      
    }
    options.join("\n").html_safe
  end
  
  def search_count_description(search_query, search_counts)
    count_list = []
    search_counts.each_pair {|item, count|
      count_list << I18n.translate("search_count.#{item}" , count: count)
    }
    I18n.t("search_count_description",count_list: count_list.to_sentence, q:search_query)
  end
end
