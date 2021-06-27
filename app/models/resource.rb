class Resource < ApplicationRecord
  belongs_to :semester
  has_many :involvements
  has_many :events

  scope :with_code, -> (code) { where('code ILIKE ? OR code_apogee ILIKE ?', code, code) }
  default_scope { order(:code) }

  # Expected student hours

  def expected_student_hours
    hours_cm + hours_tp
  end

  def hours_td
    0
  end

  def events_for_year(year)
    promotion = year.promotion_for_semester(semester)
    events.where(promotion: promotion).ordered
  end

  def to_s
    "#{code} - #{label}"
  end
end
