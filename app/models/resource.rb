class Resource < ApplicationRecord
  belongs_to :semester
  has_many :involvements

  scope :with_code, -> (code) { where('code ILIKE ? OR code_apogee ILIKE ?', code, code) }
  default_scope { order(:code) }

  def expected_student_hours
    0
  end

  def to_s
    "#{code} - #{label}"
  end
end
