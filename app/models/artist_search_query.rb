class ArtistSearchQuery < SearchQuery 
  def self.query_expressions
    superclass.query_expressions.merge({name: / name:[ "]*(.+?)[ "]* /, 
      birth_date: / birth_date:[ "]*(.+?)[ "]* /,
      birth_location: / birth_location:[ "]*(.+?)[ "]* /,
      death_date: / death_date:[ "]*(.+?)[ "]* /,
      death_location: / death_location:[ "]*(.+?)[ "]* /
    })
  end
  def self.catch_all
    "name"
  end 
end
