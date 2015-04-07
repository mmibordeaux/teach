class AddDescriptionToInvolvements < ActiveRecord::Migration
  def change
    add_column :involvements, :description, :text
  end
end
