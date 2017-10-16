class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  add_breadcrumb 'Tableau de bord', :root_path

  def parse
    render json: PPN.parse
  end
end
