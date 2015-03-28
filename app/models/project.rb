# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  label       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#

class Project < ActiveRecord::Base

  has_many :fields_projects
  has_many :fields, through: :fields_projects
  has_many :projects_semesters
  has_many :semesters, through: :projects_semesters
  has_many :teaching_modules, through: :fields
  
  accepts_nested_attributes_for :fields_projects, allow_destroy: true
  accepts_nested_attributes_for :fields
  accepts_nested_attributes_for :projects_semesters, allow_destroy: true
  accepts_nested_attributes_for :semesters

  def to_s
    "#{label}"
  end

end
