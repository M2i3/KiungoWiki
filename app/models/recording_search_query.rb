class RecordingSearchQuery < SearchQuery 
  def self.query_expressions
    superclass.query_expressions.merge({ title: / title:(.+?) /,
      recording_date: / recording_date:(.+?) /,
      duration: / duration:(.+?) /,
      artist_wiki_link: / artist_wiki_link:(.+?) /,
      album_wiki_link: / album_wiki_link:(.+?) /,
      recording_location:  / recording_location:(.+?) /,
      rythm: / rythm:(.+?) /,
      trackNb: / trackNb:([0-9]+) /,
      itemId: / itemId:([0-9a-zA-Z]+) /,
      itemSection: / itemSection:([A-Z1-9]) /
    })
  end
  def self.catch_all
    "title"
  end 
end

