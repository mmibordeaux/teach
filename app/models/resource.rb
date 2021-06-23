class Resource < ApplicationRecord
  belongs_to :semester
  has_many :involvements

  scope :with_code, -> (code) { where('code ILIKE ? OR code_apogee ILIKE ?', code, code) }
  default_scope { order(:code) }

  # Expected student hours

  def expected_student_hours
    hours_cm + hours_tp
  end

  def to_s
    "#{code} - #{label}"
  end
end
