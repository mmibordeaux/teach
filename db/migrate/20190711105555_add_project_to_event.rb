class AddProjectToEvent < ActiveRecord::Migration
  def change
    add_reference :events, :project, index: true, foreign_key: true
  end
end
