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

require 'test_helper'

class TeachingSubjectTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
