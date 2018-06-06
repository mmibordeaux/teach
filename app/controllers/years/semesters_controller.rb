class Years::SemestersController < YearsController
  def index
    @title = 'Semestres'
    @semesters = Semester.all
    breadcrumb
  end

  def show
    @semester = Semester.find params[:id]
    @objectives = @semester.objectives
    @projects = @year.projects.in_semester(@semester)
    @objectives_covered = @objectives.where(id: @year.objectives)
    @objectives_not_covered = @objectives - @objectives_covered
    @title = "#{@semester}"
    @subtitle = "#{@year}"
    breadcrumb
  end

  protected

  def breadcrumb
    super
    add_breadcrumb 'Semestres', year_semesters_path(year_id: @year.id)
    add_breadcrumb @semester, [@year, @semester] if @semester
  end
end