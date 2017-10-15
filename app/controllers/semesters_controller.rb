class SemestersController < ApplicationController
  def index
    @semesters = Semester.all
    @title = 'Semestres'
  end

  def show
    @semester = Semester.find params[:id]
    @title = @semester
  end
end
