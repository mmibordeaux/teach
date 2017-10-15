class DashboardController < ApplicationController
  skip_load_and_authorize_resource
  def index
  	@title = 'Admin'
  	@subtitle = 'L\'outil d\'organisation des enseignements de MMI Bordeaux'
    @semesters = Semester.all
  end
end