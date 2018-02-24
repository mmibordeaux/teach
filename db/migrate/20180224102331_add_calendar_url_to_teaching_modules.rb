class AddCalendarUrlToTeachingModules < ActiveRecord::Migration
  def change
    add_column :teaching_modules, :calendar_url, :string
  end
end
