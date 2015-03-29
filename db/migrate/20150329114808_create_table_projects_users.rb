class CreateTableProjectsUsers < ActiveRecord::Migration
  def change
    create_table :table_projects_users do |t|
      t.integer :project_id
      t.integer :user_id
    end
  end
end
