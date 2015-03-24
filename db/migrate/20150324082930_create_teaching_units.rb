class CreateTeachingUnits < ActiveRecord::Migration
  def change
    create_table :teaching_units do |t|
      t.integer :number

      t.timestamps null: false
    end
  end
end
