class InvolvementsController < ApplicationController
  load_and_authorize_resource

  def index
    @involvements = Involvement.all
  end

  def show
  end

  def new
    @year = Year.find params[:year_id]
    @project = Project.find params[:project_id]
    @promotions = @year.nil? ? Promotion.all : @year.promotions
    @involvement = Involvement.new
    @involvement.project = @project
    @involvement.user_id = params[:user_id] if params.include? :user_id
    @involvement.teaching_module_id = params[:teaching_module_id] if params.include? :teaching_module_id
    @title = 'Planifier une intervention'
    add_breadcrumb 'Années', years_path
    add_breadcrumb @year, @year
    add_breadcrumb @project, @project
    add_breadcrumb @title
  end

  def edit
    @year = Year.find params[:year_id]
    @project = @involvement.project
    @promotions = @year.nil? ? Promotion.all : @year.promotions
    @title = 'Modifier une planification'
    add_breadcrumb 'Années', years_path
    add_breadcrumb @year, @year
    add_breadcrumb @project, @project
    add_breadcrumb @title
  end

  def create
    @involvement = Involvement.new(involvement_params)
    if @involvement.save
      redirect_to @involvement.project, notice: 'Involvement was successfully created.'
    else
      render :new
    end
  end

  def update
    if @involvement.update(involvement_params)
      redirect_to @involvement.project, notice: 'Involvement was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    project = @involvement.project
    @involvement.destroy
    redirect_to project, notice: 'Involvement was successfully destroyed.'
  end

  private

  def involvement_params
    params.require(:involvement).permit(:teaching_module_id, :user_id, :project_id, :promotion_id, :hours_cm, :hours_td, :hours_tp, :description, :multiplier_td, :multiplier_tp, :groups_tp)
  end
end
