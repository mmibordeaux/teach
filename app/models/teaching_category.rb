# == Schema Information
#
# Table name: teaching_categories
#
#  id         :integer          not null, primary key
#  label      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TeachingCategory < ActiveRecord::Base

  has_many :teaching_modules

  def to_s
    "#{label}"
  end

end
