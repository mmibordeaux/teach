class Rename < ActiveRecord::Migration
  def change
    rename_table :table_projects_users, :projects_users
  end
end
