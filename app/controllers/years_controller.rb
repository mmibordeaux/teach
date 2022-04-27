class YearsController < ApplicationController
  load_and_authorize_resource except: :user
  before_action :load_year

  def index
    Year.create_necessary
    @years = Year.order(year: :desc)
    @title = 'Années'
    breadcrumb
  end

  def show
    redirect_to year_projects_path(@year)
  end

  protected

  def load_year
    @year = Year.find params[:year_id] if params.include? :year_id
  end

  def breadcrumb
    add_breadcrumb 'Années', :years_path
    add_breadcrumb @year, @year if @year
  end
end
