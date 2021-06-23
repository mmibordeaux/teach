class RemoveTdFromResources < ActiveRecord::Migration[5.2]
  def change
    remove_column :resources, :hours_td
  end
end
