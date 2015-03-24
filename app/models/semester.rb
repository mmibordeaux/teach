# == Schema Information
#
# Table name: semesters
#
#  id         :integer          not null, primary key
#  number     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Semester < ActiveRecord::Base

  def to_s
    "S#{number}"
  end

end
