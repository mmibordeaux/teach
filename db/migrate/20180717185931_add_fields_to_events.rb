class AddFieldsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :label, :string
    add_column :events, :description, :text
  end
end
