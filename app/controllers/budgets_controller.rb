class BudgetsController < ApplicationController
  def users
    @users = User.all.order(:last_name, :first_name)
    @title = 'Budget par intervenant'
  end

  def teaching_modules
    @semesters = Semester.all
    @title = 'Budget par module'
  end
end