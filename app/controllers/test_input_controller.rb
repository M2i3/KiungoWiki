class TestInputController < ApplicationController
  before_filter :control_access
  
  def text_encoding
  end
  
  def work_search_query
    if params[:search_query]
      @search_query = WorkWikiLink::SearchQuery.new(params[:search_query])
    end
  end
  
  protected
  def control_access
    authorize!(params[:action].to_sym, TestInputController)
  end
end
