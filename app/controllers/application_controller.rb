class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  load_and_authorize_resource

  def parse
    render json: PPN.parse
  end
end
