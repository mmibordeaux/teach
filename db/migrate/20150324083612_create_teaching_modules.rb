class CreateTeachingModules < ActiveRecord::Migration
  def change
    create_table :teaching_modules do |t|
      t.string :code
      t.string :label
      t.text :objectives
      t.text :content
      t.text :how_to
      t.text :what_next
      t.integer :hours
      t.integer :semester_id
      t.integer :teaching_subject_id
      t.integer :teaching_unit_id
      t.integer :teaching_category_id
      t.integer :coefficient

      t.timestamps null: false
    end
  end
end
