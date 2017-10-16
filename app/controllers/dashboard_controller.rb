class DashboardController < ApplicationController
  def index
  	@title = 'Tableau de bord'
  	@subtitle = '<strong>mmi admin</strong> • L\'outil d\'organisation des enseignements de MMI Bordeaux'
    @semesters = Semester.all
  end
end