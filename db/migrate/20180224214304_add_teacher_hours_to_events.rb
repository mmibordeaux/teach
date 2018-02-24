class AddTeacherHoursToEvents < ActiveRecord::Migration
  def change
    add_column :events, :teacher_hours, :float
  end
end
