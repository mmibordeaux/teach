# == Schema Information
#
# Table name: projects
#
#  id          :integer          not null, primary key
#  label       :string
#  semester_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
