module ApplicationHelper
  include  M2i3WebBase::PageHelper

  def work_wiki_link_path(wiki_link)
    wiki_link = wiki_link.to_wiki_link unless wiki_link.is_a?(WikiLink)
    link_to(wiki_link.title, work_path(id:wiki_link.searchref.url_encoded))
  end
    
  def artist_wiki_link_path(wiki_link)
    wiki_link = wiki_link.to_wiki_link unless wiki_link.is_a?(WikiLink)
    link_to(wiki_link.name, artist_path(id:wiki_link.searchref.url_encoded))
  end

  def release_wiki_link_path(wiki_link)
    wiki_link = wiki_link.to_wiki_link unless wiki_link.is_a?(WikiLink)
    link_to(wiki_link.title, release_path(id:wiki_link.searchref.url_encoded))
  end
  
  def recording_wiki_link_path(wiki_link)
    wiki_link = wiki_link.to_wiki_link unless wiki_link.is_a?(WikiLink)
		link_to(wiki_link.title, recording_path(id:wiki_link.searchref.url_encoded))
  end

  def category_wiki_link_path(wiki_link)
    wiki_link = wiki_link.to_wiki_link unless wiki_link.is_a?(WikiLink)
		link_to(wiki_link.category_name, category_path(id:wiki_link.searchref.url_encoded))
  end

  def tokeninput_formatted_combined_link(combined_link)
    if combined_link
      [combined_link].to_json
    else
      ""
    end
  end

  def format_date(date)
    if date
      I18n.l(date.to_date)
    else
      ""
    end
  end
  
  def format_combined_link_pre(combined_link)
    if combined_link == {:id=>"", :name=>""}
      ''
    else
      [combined_link].to_json
    end
  end

  def current_page_classes(params ={}, classes="")
    if current_page?(params)
      [classes, "active"].join(" ")
    else
      classes
    end
  end

  def site_message_class(msg_type)
   ({:info=>"alert-info", :error=>"alert-error", :alert=>"", :warning=>"", :notice=>"alert-success"}[msg_type]).to_s
  end
  
  def updated_at(resource)
    t('updated_at', update_date:resource.updated_at.strftime('%Y-%m-%d'), update_time:resource.updated_at.strftime('%H:%M'), update_username:resource.modifier.try(:nickname))
  end
  
  def sharethis_enabled?
    !sharethis_publisher_id.nil?
  end
  def sharethis_publisher_id
    ENV['SHARETHIS_PUBLISHER']
    #"323da19c-f0a0-4030-87cb-7b76e958f722"
  end
end
