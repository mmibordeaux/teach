class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  add_breadcrumb 'Tableau de bord', :dashboard_path

  def parse
    render json: PPN.parse
  end

  # def current_user
  #   User.with_email('beatrice.lemoine@mmibordeaux.com').first
  # end
end
