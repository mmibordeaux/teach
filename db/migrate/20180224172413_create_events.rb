class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.date :date
      t.float :duration
      t.references :teaching_module, index: true, foreign_key: true
      t.references :promotion, index: true, foreign_key: true
      t.integer :kind

      t.timestamps null: false
    end
  end
end
