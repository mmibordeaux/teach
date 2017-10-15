class DashboardController < ApplicationController
  def index
  	@title = 'Admin'
  	@subtitle = 'L\'outil d\'organisation des enseignements de MMI Bordeaux'
    @semesters = Semester.all
  end
end