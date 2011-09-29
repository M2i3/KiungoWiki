module ApplicationHelper
  include  M2i3WebBase::PageHelper

  def work_wiki_link_path(wwl)
    if wwl.work_id
      link_to(wwl.title, work_path(:id=>wwl.work_id))
    else
      link_to(wwl.title, works_path(:q=>wwl.reference))
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
