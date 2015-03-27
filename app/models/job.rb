# == Schema Information
#
# Table name: jobs
#
#  id         :integer          not null, primary key
#  label      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Job < ActiveRecord::Base
  has_many :fields_jobs
  has_many :fields, through: :fields_jobs
  
  accepts_nested_attributes_for :fields_jobs, allow_destroy: true
  accepts_nested_attributes_for :fields
  
  def to_s
    "#{label}"
  end

end
