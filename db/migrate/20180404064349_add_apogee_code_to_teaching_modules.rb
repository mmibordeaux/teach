class AddApogeeCodeToTeachingModules < ActiveRecord::Migration
  def change
    add_column :teaching_modules, :code_apogee, :string
  end
end
