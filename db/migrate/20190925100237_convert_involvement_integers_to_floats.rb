class ConvertInvolvementIntegersToFloats < ActiveRecord::Migration
  def change
    change_column :involvements, :hours_cm, :float, default: 0.0, null: false
    change_column :involvements, :hours_td, :float, default: 0.0, null: false
    change_column :involvements, :hours_tp, :float, default: 0.0, null: false
  end
end
