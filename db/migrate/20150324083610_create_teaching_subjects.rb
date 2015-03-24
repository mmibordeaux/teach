class CreateTeachingSubjects < ActiveRecord::Migration
  def change
    create_table :teaching_subjects do |t|
      t.integer :label
      t.integer :teaching_unit_id

      t.timestamps null: false
    end
  end
end
