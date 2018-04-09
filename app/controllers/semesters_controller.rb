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

  def show_in_year
    @year = Year.find params[:year_id]
    @semester = Semester.find params[:id]
    @projects = @year.projects.in_semester(@semester)
    @objectives = @semester.objectives
    @objectives_covered = @objectives.where(id: @year.objectives)
    @objectives_not_covered = @objectives - @objectives_covered
    @title = "#{@semester}" 
    @subtitle = "#{@year}"
    add_breadcrumb @year, @year
    add_breadcrumb @semester
  end
end
