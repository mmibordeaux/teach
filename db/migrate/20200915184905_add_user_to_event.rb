class AddUserToEvent < ActiveRecord::Migration[5.2]
  def change
    add_reference :events, :user, foreign_key: true
    drop_table :events_users
  end
end
