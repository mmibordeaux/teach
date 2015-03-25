# == Schema Information
#
# Table name: teaching_modules
#
#  id                   :integer          not null, primary key
#  code                 :string
#  label                :string
#  content              :text
#  how_to               :text
#  what_next            :text
#  hours                :integer
#  semester_id          :integer
#  teaching_subject_id  :integer
#  teaching_unit_id     :integer
#  teaching_category_id :integer
#  coefficient          :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class TeachingModule < ActiveRecord::Base
  belongs_to :teaching_unit
  belongs_to :teaching_subject
  belongs_to :teaching_category
  belongs_to :semester
  has_many :objectives
  has_many :keywords

  #default_scope { order('semester_id') }

  def to_s
    "#{code}"
  end

  def full_name
    "#{code} - #{label}"
  end

end
