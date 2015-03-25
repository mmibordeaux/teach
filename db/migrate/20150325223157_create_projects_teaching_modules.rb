class CreateProjectsTeachingModules < ActiveRecord::Migration
  def change
    create_table :projects_teaching_modules do |t|
      t.integer :project_id
      t.integer :teaching_module_id

      t.timestamps null: false
    end
  end
end
