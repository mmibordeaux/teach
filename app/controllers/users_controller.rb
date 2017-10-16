class UsersController < ApplicationController
  load_and_authorize_resource

  add_breadcrumb 'Equipe', :users_path

  def index
    @users = User.all.order(:last_name, :first_name)
    @title = 'Equipe'
  end

  def summary
    @users = User.all.order(:last_name, :first_name)
    @teacher_hours = Involvement.teacher_hours
    @tenured_teacher_hours = Involvement.tenured_teacher_hours
    @untenured_teacher_hours = Involvement.untenured_teacher_hours
    @title = 'Services'
    @subtitle = 'Répartition des heures du point de vue enseignant'
    add_breadcrumb 'Services'
  end

  def show
    @title = @user.to_s
    @subtitle = @user.email
    add_breadcrumb @user, @user
  end

  def new
    @user = User.new
  end

  def edit
    add_breadcrumb @user, @user
    add_breadcrumb 'Modifier'
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def reset
    @user.send_reset_password_instructions
    redirect_to :back
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def user_params
    parameters = params.require(:user).permit(:first_name, :last_name, :hours, :public, :tenured, :email, project_ids: [], teaching_module_ids: [], field_ids: [])
    parameters = parameters.merge({ admin: params[:user][:admin] }) if current_user.admin?
    parameters
  end
end
