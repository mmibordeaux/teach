class Years::TeachingModulesController < YearsController
  def index
    @teaching_modules = TeachingModule.all.order(:semester_id)
    @student_hours = @year.student_hours
    @teacher_hours = @year.teacher_hours
    @title = 'Projets'
    @subtitle = @year.to_s
    breadcrumb
  end

  def show
    @title = @teaching_module.full_name
    @subtitle = @year.to_s
    breadcrumb
  end

  protected

  def breadcrumb
    super
    add_breadcrumb 'Modules', year_teaching_modules_path(year_id: @year.id)
    add_breadcrumb @teaching_module if @teaching_module
  end
end
