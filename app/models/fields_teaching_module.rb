# == Schema Information
#
# Table name: fields_teaching_modules
#
#  id                 :integer          not null, primary key
#  field_id           :integer
#  teaching_module_id :integer
#

class FieldsTeachingModule < ActiveRecord::Base
  belongs_to :field
  belongs_to :teaching_module
end
