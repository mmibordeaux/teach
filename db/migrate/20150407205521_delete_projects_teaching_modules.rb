class DeleteProjectsTeachingModules < ActiveRecord::Migration
  def change
    drop_table :projects_teaching_modules
  end
end
