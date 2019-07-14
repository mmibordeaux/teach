class Years::UsersController < YearsController
  def index
    @title = 'Equipe'
    @users = @year.users
    breadcrumb
  end

  def show
    @user = User.find params[:id]
    @title = @user
    @projects_in_charge = @year.projects.where(user: @user)
    breadcrumb
  end

  protected

  def breadcrumb
    super
    add_breadcrumb 'Equipe', year_users_path(year_id: @year.id)
    add_breadcrumb @user, [@year, @user] if @user
  end
end