class WorkWikiLink
  include Mongoid::Document
  include WikiLink

  set_reference_class Work, WorkSearchQuery

  accepts_nested_attributes_for :work
  belongs_to :work, inverse_of: nil

  def title
    (self.work && self.work.title) ||self.objectq
  end

  def work_wiki_links
     (self.work && self.work.work_wiki_links) || ""
  end

  def language_code
     (self.work && self.work.language_code) || ""
  end

  def language_name
    unless["0","",nil].include?(Language.where(:language_code=>self.language_code).first); 
                Language.where(:language_code=>self.language_code).first[:language_name_french]; 
    end
  end

  def object_text
    self.title.to_s 
  end

  def date_written
    work.date_written if work
  end

  def relation
    searchref[:relation]
  end

end
