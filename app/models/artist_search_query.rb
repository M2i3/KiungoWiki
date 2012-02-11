class ArtistSearchQuery < SearchQuery 
  def self.query_expressions
    superclass.query_expressions.merge({surname: / surname:[ "]*(.+?)[ "]* /,
      given_name: / given_name:[ "]*(.+?)[ "]* /, 
      birth_date: / birth_date:[ "]*(.+?)[ "]* /,
      birth_location: / birth_location:[ "]*(.+?)[ "]* /,
      death_date: / death_date:[ "]*(.+?)[ "]* /,
      death_location: / death_location:[ "]*(.+?)[ "]* /,
      role: / role:([0-9a-zA-Z]+) /
    })
  end
  def self.catch_all
    "name"   #TODO ajouter recherche sur prenoms itou
  end 
end
