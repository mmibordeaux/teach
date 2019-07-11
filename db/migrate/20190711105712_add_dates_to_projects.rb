class AddDatesToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :from, :date
    add_column :projects, :to, :date
  end
end
