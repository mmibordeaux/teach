class AddUserToTeachingModule < ActiveRecord::Migration
  def change
    add_column :teaching_modules, :user_id, :integer
  end
end
