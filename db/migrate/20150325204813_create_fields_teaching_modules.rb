class CreateFieldsTeachingModules < ActiveRecord::Migration
  def change
    create_table :fields_teaching_modules do |t|
      t.integer :field_id
      t.integer :teaching_module_id
    end
  end
end
