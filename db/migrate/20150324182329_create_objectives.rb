class CreateObjectives < ActiveRecord::Migration
  def change
    create_table :objectives do |t|
      t.string :label
      t.integer :teaching_module_id

      t.timestamps null: false
    end
  end
end
