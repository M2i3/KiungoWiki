class ArtistSearchQuery < SearchQuery 
  def self.query_expressions
    superclass.query_expressions.merge({name: / name:[ "]*(.+?)[ "]* /, 
      birth_date: / birth_date:[ ]*([0-9]{4,4}(\-|\/)[0-9]{1,2}(\-|\/)[0-9]{1,2}) /,
      birth_location: / birth_location:[ "]*(.+?)[ "]* /,
      death_date: / death_date:[ ]*([0-9]{4,4}(\-|\/)[0-9]{1,2}(\-|\/)[0-9]{1,2}) /,
      death_location: / death_location:[ "]*(.+?)[ "]* /
    })
  end
  def self.catch_all
    "name"
  end 
end
