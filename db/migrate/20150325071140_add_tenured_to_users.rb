class AddTenuredToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tenured, :boolean
  end
end
