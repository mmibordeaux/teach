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
#

class Event < ActiveRecord::Base
  belongs_to :teaching_module
  belongs_to :promotion
  has_and_belongs_to_many :users
  
  scope :in_semester, -> (semester) { where(teaching_module: semester.teaching_modules) }

  enum kind: [:cm, :td, :tp]
end
