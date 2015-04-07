class RefactorInvolvements < ActiveRecord::Migration
  def change
    rename_column :involvements, :project_id, :teaching_module_id
  end
end
