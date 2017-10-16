module ApplicationHelper
  def to_human_time(hours)
    days = (hours/8.0).ceil
    weeks = (days/5.0).ceil
    raw "#{days} jours, <strong>#{weeks} semaines</strong>"
  end
end