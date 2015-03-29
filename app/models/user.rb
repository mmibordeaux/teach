# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  first_name :string
#  last_name  :string
#  hours      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  tenured    :boolean
#

class User < ActiveRecord::Base

  default_scope { order('last_name, first_name') }

  has_many :teaching_modules
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :fields

  accepts_nested_attributes_for :teaching_modules
  accepts_nested_attributes_for :projects
  accepts_nested_attributes_for :fields

  STUDENTS_HOURS = 1600
  BUDGET = 100000
  PER_HOUR_PRICE = 60
  EXTRA_HOURS = BUDGET / PER_HOUR_PRICE
  
  def to_s
    "#{first_name} #{last_name}"
  end

end
