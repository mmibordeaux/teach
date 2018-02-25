# == Schema Information
#
# Table name: events
#
#  id                 :integer          not null, primary key
#  date               :date
#  duration           :float
#  teaching_module_id :integer
#  promotion_id       :integer
#  kind               :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  student_hours      :float
#

class Event < ActiveRecord::Base
  belongs_to :teaching_module
  belongs_to :promotion
  has_and_belongs_to_many :users
  
  scope :in_semester, -> (semester) { where(teaching_module: semester.teaching_modules) }

  enum kind: [:cm, :td, :tp]

  before_save :compute_student_hours

  protected

  def compute_student_hours
    users_count = users.any? ? users.count : 1
    self.teacher_hours = self.duration * users_count
    groups = 1.0
    groups = Involvement::GROUPS_TD if td?
    groups = Involvement::GROUPS_TP if tp?
    self.student_hours = self.teacher_hours / groups
  end
end
