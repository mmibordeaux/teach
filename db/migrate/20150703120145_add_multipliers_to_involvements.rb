class AddMultipliersToInvolvements < ActiveRecord::Migration
  def change
    add_column :involvements, :multiplier_td, :integer, default: 2
    add_column :involvements, :multiplier_tp, :integer, default: 3
  end
end
