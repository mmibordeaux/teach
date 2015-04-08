class InvolvementsDefaults < ActiveRecord::Migration
  def change
    change_column :involvements, :hours_cm, :integer, default: 0
    change_column :involvements, :hours_td, :integer, default: 0
    change_column :involvements, :hours_tp, :integer, default: 0
  end
end
