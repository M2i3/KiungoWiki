module ApplicationHelper
  include  M2i3WebBase::PageHelper

  def format_date(date)
    if date
      I18n.l(date.to_date)
    else
      ""
    end
  end
end
