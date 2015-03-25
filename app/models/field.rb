# == Schema Information
#
# Table name: fields
#
#  id         :integer          not null, primary key
#  label      :string
#  parent_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  position   :integer
#

class Field < ActiveRecord::Base

  belongs_to :parent, class_name: Field
  has_many :children, class_name: Field, foreign_key: :parent_id
  has_many :fields_teaching_modules
  has_many :teaching_modules, through: :fields_teaching_modules
  has_many :fields_projects
  has_many :projects, through: :fields_projects
  
  accepts_nested_attributes_for :fields_teaching_modules, allow_destroy: true
  accepts_nested_attributes_for :teaching_modules
  accepts_nested_attributes_for :fields_projects, allow_destroy: true
  accepts_nested_attributes_for :projects
  
  def hours
    teaching_modules.sum(:hours)
  end

  def to_s
    "#{label}"
  end

end
