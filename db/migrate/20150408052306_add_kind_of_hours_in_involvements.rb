class AddKindOfHoursInInvolvements < ActiveRecord::Migration
  def change
    rename_column :involvements, :hours, :hours_cm
    add_column :involvements, :hours_td, :integer
    add_column :involvements, :hours_tp, :integer
  end
end
