class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.string :label
      t.integer :parent_id

      t.timestamps null: false
    end
  end
end
