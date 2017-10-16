class SemestersController < ApplicationController
  load_and_authorize_resource

  def index
    @semesters = Semester.all
    @title = 'Semestres'
  end

  def show
    @semester = Semester.find params[:id]
    @title = @semester
  end
end
