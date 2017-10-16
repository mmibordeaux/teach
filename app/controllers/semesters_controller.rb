class SemestersController < ApplicationController
  load_and_authorize_resource

  add_breadcrumb 'Semestres', :semesters_path

  def index
    @semesters = Semester.all
    @title = 'Semestres'
  end

  def show
    @semester = Semester.find params[:id]
    @title = @semester
    add_breadcrumb @semester
  end
end
