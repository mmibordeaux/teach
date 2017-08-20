class AddProjectToInvolvement < ActiveRecord::Migration
  def change
    add_column :involvements, :project_id, :integer
  end
end
