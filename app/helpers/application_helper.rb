module ApplicationHelper
  include  M2i3WebBase::PageHelper

  def work_wiki_link_path(wwl)
    if wwl.work_id
      link_to(wwl.title, work_path(:id=>wwl.work_id))
    else
      link_to(wwl.title, works_path(:q=>wwl.reference_text))
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
      link_to(awl.name, artist_path(:id=>awl.artist_id))
    else
      link_to(awl.name, artists_path(:q=>awl.reference_text))
    end
  end

  def album_wiki_link_path(awl)
    if awl.album_id
      link_to(awl.title, album_path(:id=>awl.album_id))
    else
      link_to(awl.title, albums_path(:q=>awl.reference_text))
    end
  end
  
  def recording_wiki_link_path(rwl)
  	if rwl.recording_id
  		link_to(rwl.title, recording_path(:id=>rwl.recording_id))
  	else
  		link_to(rwl.title, recordings_path(:q=>rwl.reference_text))
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

  def owned_wiki_link_path(owl)    
    case
      when owl.respond_to?(:album_id) && owl.album_id
        album_wiki_link_path(owl)
      when owl.respond_to?(:recording_id) && owl.recording_id
        recording_wiki_link_path(owl)        
      else
        "n/a"
    end
  end

  def rating_to_star(rating)
    render :partial=>"common/rating_to_star", :object=>rating.to_i
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
end
