class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate

  def parse
    render json: PPN.parse
  end
  
  protected

    def authenticate
      if Rails.env.production?
        authenticate_or_request_with_http_basic do |username, password|
          username == ENV['MMI_USERNAME'] && password == ENV['MMI_PASSWORD']
        end
      end
    end

end
