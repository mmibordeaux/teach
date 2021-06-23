class AddResourceToEvents < ActiveRecord::Migration[5.2]
  def change
    add_reference :events, :resource
  end
end
