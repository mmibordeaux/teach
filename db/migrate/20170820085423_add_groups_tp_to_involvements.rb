class AddGroupsTpToInvolvements < ActiveRecord::Migration
  def change
    add_column :involvements, :groups_tp, :integer, default: 3
  end
end
