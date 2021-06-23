class Years::ResourcesController < YearsController
  def index
    @resources = Resource.all
    @title = 'Ressources'
    @subtitle = @year.to_s
    breadcrumb
  end

  def show
    @title = @resource.to_s
    @subtitle = @year.to_s
    breadcrumb
  end

  protected

  def breadcrumb
    super
    add_breadcrumb 'Modules', year_resources_path(year_id: @year.id)
    add_breadcrumb @resource if @resource
  end
end
