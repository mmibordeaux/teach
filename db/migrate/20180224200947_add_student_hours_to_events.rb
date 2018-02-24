class AddStudentHoursToEvents < ActiveRecord::Migration
  def change
    add_column :events, :student_hours, :float
  end
end
