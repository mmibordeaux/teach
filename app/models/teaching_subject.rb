# == Schema Information
#
# Table name: teaching_subjects
#
#  id               :integer          not null, primary key
#  label            :string
#  teaching_unit_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class TeachingSubject < ActiveRecord::Base

  belongs_to :teaching_unit

  def to_s
    "#{label}"
  end

end
