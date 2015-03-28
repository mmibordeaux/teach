class AddColorToFields < ActiveRecord::Migration
  def change
    add_column :fields, :color, :string
  end
end
