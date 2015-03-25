class CreateFieldsProjects < ActiveRecord::Migration
  def change
    create_table :fields_projects do |t|
      t.integer :field_id
      t.integer :project_id

      t.timestamps null: false
    end
  end
end
