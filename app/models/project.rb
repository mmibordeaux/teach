# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  label       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#  position    :integer
#  user_id     :integer
#

class Project < ActiveRecord::Base

  has_many :fields_projects, dependent: :destroy
  has_many :fields, through: :fields_projects
  has_many :projects_semesters, dependent: :destroy
  has_many :semesters, through: :projects_semesters
  has_and_belongs_to_many :users
  belongs_to :user
  
  accepts_nested_attributes_for :fields_projects, allow_destroy: true
  accepts_nested_attributes_for :fields
  accepts_nested_attributes_for :projects_semesters, allow_destroy: true
  accepts_nested_attributes_for :semesters

  default_scope { order('position') }

  # Modules though fields, filtered by semesters
  def teaching_modules
    list = []
    fields.each do |field|
      field.teaching_modules.each do |teaching_module|
        list << teaching_module if semesters.include? teaching_module.semester
      end
    end
    list.uniq!
    list
  end

  def to_s
    "#{label}"
  end

end
