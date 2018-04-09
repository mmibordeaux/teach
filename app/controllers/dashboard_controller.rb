class DashboardController < ApplicationController
  def index
  	@title = 'Tableau de bord'
  	@subtitle = '<strong>mmi teach</strong> | L\'outil d\'organisation des enseignements de MMI Bordeaux'
    @semesters = Semester.all
    @year = Year.current
  end
end