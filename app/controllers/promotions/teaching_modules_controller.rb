class Promotions::TeachingModulesController < PromotionsController
  def index
    @teaching_modules = TeachingModule.all.order(:semester_id)
    @title = 'Modules'
    @subtitle = @promotion.to_s
    @semesters = Semester.all
    @student_hours = TeachingModule.sum :hours
    @student_hours_cm = TeachingModule.sum :hours_cm
    @student_hours_td = TeachingModule.sum :hours_td
    @student_hours_tp = TeachingModule.sum :hours_tp
    breadcrumb
  end

  protected

  def breadcrumb
    super
    add_breadcrumb 'Modules', promotion_teaching_modules_path(promotion_id: @promotion.id)
  end
end
