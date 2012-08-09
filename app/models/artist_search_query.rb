class ArtistSearchQuery < SearchQuery 
  def self.query_expressions
    superclass.query_expressions.merge({surname: :text,
      given_name: :text,
      name: :text,
      birth_date: :date,
      birth_location: :text,
      death_date: :date,
      death_location: :text,
      role: :text,
      info: :text,
      relation: :text
    })
  end
  def self.catch_all
    "name"
  end 
  def self.meta_fields
    super + [:role]
  end
end
