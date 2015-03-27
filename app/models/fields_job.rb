# == Schema Information
#
# Table name: fields_jobs
#
#  id         :integer          not null, primary key
#  field_id   :integer
#  job_id     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FieldsJob < ActiveRecord::Base
  belongs_to :field
  belongs_to :job
end
