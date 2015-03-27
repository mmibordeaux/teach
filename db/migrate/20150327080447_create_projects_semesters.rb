class CreateProjectsSemesters < ActiveRecord::Migration
  def change
    create_table :projects_semesters do |t|
      t.integer :project_id
      t.integer :semester_id

      t.timestamps null: false
    end

    remove_column :projects, :semester_id
  end
end
