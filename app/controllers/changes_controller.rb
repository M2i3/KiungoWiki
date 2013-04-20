class ChangesController < ApplicationController
  def index
    @changes = Change.all
    @changes = @changes.where(scope:params[:scope]) if params[:scope]
    @changes = @changes.order_by(_id: -1).page(params[:page])
  end
end
