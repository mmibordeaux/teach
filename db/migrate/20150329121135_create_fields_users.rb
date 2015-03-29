class CreateFieldsUsers < ActiveRecord::Migration
  def change
    create_table :fields_users do |t|
      t.integer :field_id
      t.integer :user_id
    end
  end
end
