class Promotions::ProjectsController < PromotionsController
  def index
    @projects = @promotion.projects
    @title = 'Projets'
    @subtitle = @promotion.to_s
    @semesters = Semester.all
    breadcrumb
  end

  protected

  def breadcrumb
    super
    add_breadcrumb 'Projets', promotion_projects_path(promotion_id: @promotion.id)
  end
end
