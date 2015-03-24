# == Schema Information
#
# Table name: teaching_units
#
#  id         :integer          not null, primary key
#  number     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TeachingUnit < ActiveRecord::Base

  def to_s
    "UE#{number}"
  end

end
