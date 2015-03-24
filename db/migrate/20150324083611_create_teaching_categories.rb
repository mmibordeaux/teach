class CreateTeachingCategories < ActiveRecord::Migration
  def change
    create_table :teaching_categories do |t|
      t.integer :label

      t.timestamps null: false
    end
  end
end
