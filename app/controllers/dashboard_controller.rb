class DashboardController < ApplicationController
  def index
  	@title = 'Tableau de bord'
  	@subtitle = '<strong>mmi teach</strong> | L\'outil d\'organisation des enseignements de MMI Bordeaux'
    @semesters = Semester.all
    @year = Year.current
    @projects = @year.projects_for_user current_user
    @teaching_modules = @year.planned_teaching_modules_for current_user
  end
end