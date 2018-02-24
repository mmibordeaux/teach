class AddCalendarUrlToPromotion < ActiveRecord::Migration
  def change
    remove_column :teaching_modules, :calendar_url
    add_column :promotions, :calendar_url, :string
  end
end
