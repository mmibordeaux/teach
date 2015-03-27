# == Schema Information
#
# Table name: projects_semesters
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  semester_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ProjectsSemester < ActiveRecord::Base
  belongs_to :project
  belongs_to :semester
end
