module PortalArticlesHelper
  def featured_lookup(portal_article)
    {"work"=>"work_title_lookup",
     "artist"=>"artist_lookup",
     "release"=>"release_title_lookup",
     "recording"=>"recording_title_lookup",
     "category"=>"category_lookup"}[portal_article.category]
  end
end
