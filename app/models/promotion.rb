# == Schema Information
#
# Table name: promotions
#
#  id           :integer          not null, primary key
#  year         :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  calendar_url :string
#

class Promotion < ActiveRecord::Base

  def calendar_events
    return [] if calendar_url.blank?
    require 'open-uri'
    cal_file = open calendar_url
    Icalendar::Parser.new(cal_file).parse.first.events
  end

  def to_s
    "MMI #{year}"
  end
end
