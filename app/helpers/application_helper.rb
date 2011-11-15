module ApplicationHelper
  include  M2i3WebBase::PageHelper

  def work_wiki_link_path(wwl)
    if wwl.work_id
      link_to(wwl.title, work_path(:id=>wwl.work_id))
    else
      link_to(wwl.title, works_path(:q=>wwl.reference))
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
      link_to(awl.name, artists_path(:q=>awl.reference))
    end
  end

  def album_wiki_link_path(awl)
    if awl.album_id
      link_to(awl.title, album_path(:id=>awl.album_id))
    else
      link_to(awl.title, albums_path(:q=>awl.reference))
    end
  end
  
  def recording_wiki_link_path(rwl)
  	if rwl.recording_id
  		link_to(rwl.title, recording_path(:q=>rwl.reference))
  	else
  		link_to(rwl.title, recordings_path(:q=>rwl.reference))
  	end
  end

  def format_date(date)
    if date
      I18n.l(date.to_date)
    else
      ""
    end
  end
end
