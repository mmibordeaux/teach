class CreateInvolvements < ActiveRecord::Migration
  def change
    create_table :involvements do |t|
      t.integer :project_id
      t.integer :user_id
      t.integer :hours

      t.timestamps null: false
    end
  end
end
