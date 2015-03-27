# == Schema Information
#
# Table name: projects
#
#  id         :integer          not null, primary key
#  label      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Project < ActiveRecord::Base

  has_many :fields_projects
  has_many :fields, through: :fields_projects
  
  accepts_nested_attributes_for :fields_projects, allow_destroy: true
  accepts_nested_attributes_for :fields

  def to_s
    "#{label}"
  end

end
