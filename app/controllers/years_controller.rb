class YearsController < ApplicationController
  load_and_authorize_resource except: :user

  add_breadcrumb 'Années', :years_path

  def index
    Year.create_necessary
    @years = Year.all
    @title = 'Années'
    @subtitle = 'Après années, après années...'
  end

  def show
    @title = @year
    @subtitle = "Du #{ @year.from.strftime "%d/%m/%Y"} au #{@year.to.strftime "%d/%m/%Y"}"
    add_breadcrumb @year
  end

  def user
    @year = Year.find params[:year_id]
    @user = User.find params[:id]
    add_breadcrumb @year, @year
    add_breadcrumb @user
    @title = @user
    @subtitle = @year
  end
end
