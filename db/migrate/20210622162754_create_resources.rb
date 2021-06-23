class CreateResources < ActiveRecord::Migration[5.2]
  def change
    create_table :resources do |t|
      t.string :label
      t.string :code
      t.text :description
      t.integer :hours_cm, default: 0, null: false
      t.integer :hours_td, default: 0, null: false
      t.integer :hours_tp, default: 0, null: false
      t.string :code_apogee
      t.references :semester, foreign_key: true

      t.timestamps
    end
  end
end
