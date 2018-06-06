class SemestersController < ApplicationController
  load_and_authorize_resource

  def index
    @semesters = Semester.all
    @title = 'Semestres'
    add_breadcrumb 'Semestres', semesters_path
  end

  def show
    @semester = Semester.find params[:id]
    @title = @semester
    add_breadcrumb 'Semestres', semesters_path
    add_breadcrumb @semester
  end
end
