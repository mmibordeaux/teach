class DiscussController < ApplicationController
  skip_before_action :authenticate_user!
  layout 'discuss'

  def index
    @years = Year.all.order(year: :desc)
  end

  def year
    @year = Year.where(year: params[:year]).first
  end

  def project
    @project = Project.find params[:project_id]
  end
end