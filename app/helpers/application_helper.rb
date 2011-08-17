module ApplicationHelper
  include  M2i3WebBase::PageHelper

  def work_wiki_link_path(wwl)
    if wwl.work 
      link_to(wwl.title, wwl)
    else
      link_to(wwl.title, works_path(:title=>wwl.title))
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
