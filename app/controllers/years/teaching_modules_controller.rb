class Years::TeachingModulesController < YearsController
  def index
    @teaching_modules = TeachingModule.all.order(:semester_id)
    @title = 'Modules'
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
