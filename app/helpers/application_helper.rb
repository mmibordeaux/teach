module ApplicationHelper
  def to_human_time(hours)
    days = (hours/8.0).ceil
    weeks = (days/5.0).ceil
    raw "#{days} jours, <strong>#{weeks} semaines</strong>"
  end

  def button_classes(**options)
    classes = 'btn btn-primary btn-sm'
    classes += ' disabled' if options[:disabled]
    classes
  end

  def button_classes_danger(**options)
    classes = 'btn btn-danger btn-sm'
    classes += ' disabled' if options[:disabled]
    classes
  end
end
