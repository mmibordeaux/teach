# == Schema Information
#
# Table name: projects_teaching_modules
#
#  id                 :integer          not null, primary key
#  project_id         :integer
#  teaching_module_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class ProjectsTeachingModule < ActiveRecord::Base
  
  belongs_to :project
  belongs_to :teaching_module

end
