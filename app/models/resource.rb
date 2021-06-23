class Resource < ApplicationRecord
  belongs_to :semester
  has_many :involvements

  def expected_student_hours
    0
  end

  def to_s
    "#{code} - #{label}"
  end
end
