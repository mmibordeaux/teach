class BudgetsController < ApplicationController

  add_breadcrumb 'Budgets'

  def users
    @users = User.all.order(:last_name, :first_name)
    @title = 'Budget par intervenant'
    add_breadcrumb 'Intervenants'
  end

  def teaching_modules
    @semesters = Semester.all
    @title = 'Budget par module'
    add_breadcrumb 'Modules'
  end
end