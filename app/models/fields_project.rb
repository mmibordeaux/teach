# == Schema Information
#
# Table name: fields_projects
#
#  id         :integer          not null, primary key
#  field_id   :integer
#  project_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FieldsProject < ActiveRecord::Base

  belongs_to :field
  belongs_to :project
  
end
