# == Schema Information
#
# Table name: projects
#
#  id                   :integer          not null, primary key
#  label                :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  description          :text
#  position             :integer
#  user_id              :integer
#  year_id              :integer
#  detailed_description :text
#

require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
