class AddCmTdTpToTeachingModules < ActiveRecord::Migration
  def change
    add_column :teaching_modules, :hours_cm, :integer
    add_column :teaching_modules, :hours_td, :integer
    add_column :teaching_modules, :hours_tp, :integer
  end
end
