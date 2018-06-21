class Years::InvolvementsController < YearsController
  load_and_authorize_resource

  def index
    @involvements = @year.involvements
    breadcrumb
  end

  def show
  end

  def new
    @project = Project.find params[:project_id] if params.include? :project_id
    @involvement = Involvement.new
    @involvement.project = @project
    prepare
    @title = 'Nouvelle intervention'
    breadcrumb
  end

  def edit
    @project = @involvement.project
    prepare
    @year = Year.find params[:year_id] if params.include? :year_id
    @promotions = @year.nil? ? Promotion.all : @year.promotions
    @title = 'Modifier une planification'
    breadcrumb
  end

  def create
    @involvement = Involvement.new(involvement_params)
    if @involvement.save
      redirect_to [@year, @involvement.project], notice: 'Involvement was successfully created.'
    else
      @title = 'Nouvelle intervention'
      breadcrumb
      render :new
    end
  end

  def update
    if @involvement.update(involvement_params)
      redirect_to [@year, @involvement.project], notice: 'Involvement was successfully updated.'
    else
      @title = 'Modifier une planification'
      breadcrumb
      render :edit
    end
  end

  def destroy
    year = @involvement.promotion.first_year
    @involvement.destroy
    redirect_to year, notice: 'Involvement was successfully destroyed.'
  end

  private

  def load_year
    @year = Year.find params[:year_id]
  end

  def prepare
    @projects = @year.projects
    @promotions = @year.promotions
    if @involvement.project && @involvement.project.semesters.one?
      semester = @involvement.project.semesters.first
      @promotions = semester.id.in?([1, 2]) ? [@year.first_year_promotion] : [@year.second_year_promotion]
    end
    @teaching_modules = TeachingModule.all
    @teaching_modules_collection = []
    unless @project.nil?
      @teaching_modules_collection.concat prepare_teaching_modules(@project.possible_teaching_modules)
      @teaching_modules_collection.push ['---', '']
    end
    @teaching_modules_collection.concat prepare_teaching_modules(@teaching_modules)
  end

  def prepare_teaching_modules(teaching_modules)
    teaching_modules.map do |teaching_module| 
      programmed = teaching_module.expected_student_hours.round
      planned = @year.involvements.where(teaching_module: teaching_module).sum(:student_hours).round
      teaching_module_name = teaching_module.full_name
      if !planned.zero? && !programmed.zero?
        delta = 100.0 * (planned - programmed) / programmed
        teaching_module_name += " (#{delta.to_i}%)"
      end
      [teaching_module_name, teaching_module.id]
    end
  end

  def breadcrumb
    super
    if @project
      add_breadcrumb 'Projets', year_projects_path(year_id: @year.id)
      add_breadcrumb @project, [@year, @project]
    else
      add_breadcrumb 'Interventions', year_involvements_path(year_id: @year.id)
    end
    add_breadcrumb @title if @title
  end

  def involvement_params
    params.require(:involvement).permit(:teaching_module_id, :user_id, :project_id, :promotion_id, :hours_cm, :hours_td, :hours_tp, :description, :multiplier_td, :multiplier_tp, :groups_tp)
  end
end
