class Work
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Versioning

  has_many_related :work_wiki_links

  field :title
end
