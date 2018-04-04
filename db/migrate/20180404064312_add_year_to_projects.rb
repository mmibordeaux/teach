class AddYearToProjects < ActiveRecord::Migration
  def change
    add_reference :projects, :year, index: true, foreign_key: true
  end
end
