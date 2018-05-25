class ApiController < ApplicationController
  skip_before_action :authenticate_user!
  before_filter :set_default_response_format
  
  def promotion
    @promotion = Promotion.where(year: params[:year]).first
  end

  private
  
  def set_default_response_format
    request.format = :json
  end
end