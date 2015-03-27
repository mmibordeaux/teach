class CreateFieldsJobs < ActiveRecord::Migration
  def change
    create_table :fields_jobs do |t|
      t.integer :field_id
      t.integer :job_id

      t.timestamps null: false
    end
  end
end
