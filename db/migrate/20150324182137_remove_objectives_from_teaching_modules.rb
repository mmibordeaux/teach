class RemoveObjectivesFromTeachingModules < ActiveRecord::Migration
  def change
    remove_column :teaching_modules, :objectives
  end
end
