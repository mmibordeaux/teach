class DenormalizeInvolvements < ActiveRecord::Migration
  def change
    add_column :involvements, :teacher_hours_cm, :float, default: 0.0, null: false
    add_column :involvements, :teacher_hours_td, :float, default: 0.0, null: false
    add_column :involvements, :teacher_hours_tp, :float, default: 0.0, null: false
    add_column :involvements, :teacher_hours, :float, default: 0.0, null: false
    add_column :involvements, :student_hours_cm, :float, default: 0.0, null: false
    add_column :involvements, :student_hours_td, :float, default: 0.0, null: false
    add_column :involvements, :student_hours_tp, :float, default: 0.0, null: false
    add_column :involvements, :student_hours, :float, default: 0.0, null: false
  end
end
