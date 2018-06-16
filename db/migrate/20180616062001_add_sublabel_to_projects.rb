class AddSublabelToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :sublabel, :string
  end
end
