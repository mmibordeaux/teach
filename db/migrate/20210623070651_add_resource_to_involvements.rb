class AddResourceToInvolvements < ActiveRecord::Migration[5.2]
  def change
    add_reference :involvements, :resource
  end
end
