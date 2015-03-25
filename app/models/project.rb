# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  label       :string
#  semester_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Project < ActiveRecord::Base
end
