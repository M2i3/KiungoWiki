module ApplicationHelper
  include  M2i3WebBase::PageHelper

  def work_wiki_link_path(wwl)
    if wwl.work_id
      link_to(wwl.title, work_path(:id=>wwl.work_id))
    else
      link_to(wwl.title, work_path(id:wwl.searchref.url_encoded))
    end
  end
    
  def tokeninput_formatted_combined_link(combined_link)
    if combined_link
      [combined_link].to_json
    else
      ""
    end
  end

  def artist_wiki_link_path(awl)
    if awl.artist_id
      link_to(awl.name, artist_path(id:awl.artist_id))
    else
      link_to(awl.name, artist_path(id:awl.searchref.url_encoded))
#      link_to(awl.name, artists_path(q:awl.reference_text, signature:awl.reference_signature, autofollow:true))
    end
  end

  def release_wiki_link_path(rwl)
    if rwl.release_id
      link_to(rwl.title, release_path(:id=>rwl.release_id))
    else
      link_to(rwl.title, releases_path(q:rwl.reference_text, signature:rwl.reference_signature, autofollow:true))
    end
  end
  
  def recording_wiki_link_path(rwl)
  	if rwl.recording_id
  		link_to(rwl.title, recording_path(:id=>rwl.recording_id))
  	else
  		link_to(rwl.title, recordings_path(q:rwl.reference_text, signature:rwl.reference_signature, autofollow:true))
  	end
  end

  def category_wiki_link_path(cwl)
  	if cwl.category_id
  		link_to(cwl.category_name, category_path(:id=>cwl.category_id))
  	else
  		link_to(cwl.category_name, categories_path(:q=>cwl.reference_text))
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
