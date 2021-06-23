class Resource < ApplicationRecord
  belongs_to :semester
  has_many :involvements

  default_scope { order(:code) }

  def expected_student_hours
    0
  end

  def to_s
    "#{code} - #{label}"
  end
end
