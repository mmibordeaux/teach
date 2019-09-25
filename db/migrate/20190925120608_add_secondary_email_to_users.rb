class AddSecondaryEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_secondary, :string
  end
end
