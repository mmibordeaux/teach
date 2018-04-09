class CreateJoinTableProjectsObjectives < ActiveRecord::Migration
  def change
    create_join_table :objectives, :projects do |t|
      t.index [:objective_id, :project_id]
      t.index [:project_id, :objective_id]
    end
  end
end
