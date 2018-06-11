class Years::ProjectsController < YearsController
  load_and_authorize_resource

  def index
    @projects = @year.projects
    @title = 'Projets'
    @subtitle = 'Démarche pédagogique favorisant la transversalité'
    breadcrumb
  end

  def show
    @title = "#{@project}"
    @subtitle = "#{@project.description}"
    @involvements = @project.involvements.includes(:teaching_module).reorder('teaching_modules.semester_id, involvements.user_id')
    add_breadcrumb 'Années', years_path
    add_breadcrumb @project.year, @year
    add_breadcrumb 'Projets', year_projects_path(year_id: @year.id)
    add_breadcrumb @title
  end

  def new
    @title = 'Nouveau projet'
    @project = Project.new
    @project.year = @year
    add_breadcrumb 'Années', years_path
    add_breadcrumb @project.year, @year
    add_breadcrumb 'Projets', year_projects_path(year_id: @year.id)
    add_breadcrumb @title
  end

  def edit
    @title = "#{@project} - Modifier"
    add_breadcrumb 'Années', years_path
    add_breadcrumb @project.year, @year
    add_breadcrumb 'Projets', year_projects_path(year_id: @year.id)
    add_breadcrumb @project, [@year, @project]
    add_breadcrumb @title
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      redirect_to [@year, @project], notice: 'Project was successfully created.'
    else
      @title = 'Nouveau projet'
      add_breadcrumb 'Années', years_path
      add_breadcrumb 'Projets', year_projects_path(year_id: @year.id)
      add_breadcrumb @project.year, @year
      add_breadcrumb @title
      render :new
    end
  end

  def update
    if @project.update(project_params)
      redirect_to [@year, @project], notice: 'Project was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @project.destroy
    redirect_to year_projects_url(year_id: @year.id), notice: 'Project was successfully destroyed.'
  end

  private

  def breadcrumb
    super
    add_breadcrumb 'Projets', year_projects_path(year_id: @year.id)
  end

  def project_params
    params.require(:project).permit(:label, :description, :detailed_description, :position, :user_id, :year_id, field_ids: [], semester_ids: [], user_ids: [], objective_ids: [])
  end
end
