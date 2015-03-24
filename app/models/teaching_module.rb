# == Schema Information
#
# Table name: teaching_modules
#
#  id                   :integer          not null, primary key
#  code                 :string
#  label                :string
#  objectives           :text
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
end
