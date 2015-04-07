# == Schema Information
#
# Table name: involvements
#
#  id                 :integer          not null, primary key
#  teaching_module_id :integer
#  user_id            :integer
#  hours              :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  description        :text
#

class Involvement < ActiveRecord::Base
  belongs_to :teaching_module
  belongs_to :user

  def to_s
    "#{user} - #{teaching_module.code} (#{hours}h)"
  end

end
