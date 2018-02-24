class CreatePromotions < ActiveRecord::Migration
  def change
    create_table :promotions do |t|
      t.integer :year

      t.timestamps null: false
    end
  end
end
