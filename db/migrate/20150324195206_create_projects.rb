class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :label
      t.integer :semester_id

      t.timestamps null: false
    end
  end
end
