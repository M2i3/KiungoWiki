class ChangesController < ApplicationController
  def index
    @changes = Change.all.order_by(_id: -1).page(params[:page])
  end
end
