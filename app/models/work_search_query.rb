class WorkSearchQuery < SearchQuery 
  def self.query_expressions
    superclass.query_expressions.merge({ title: :text,
      copyright: :text,
      lyrics: :text,
      date_written: :date,
      language_code:  :word,
      publisher: :text,
      role: :text,
      info: :text,
      relation: :text
    })

  end
  def self.catch_all
    "title"
  end 
  def self.meta_fields
    super + [:role, :relation]
  end
end

