class FixWrongTypes < ActiveRecord::Migration
  def change
    change_column :teaching_categories, :label,  :string
    change_column :teaching_subjects, :label,  :string
  end
end
