module ApplicationHelper
  def flash_class(type)
    case type.to_sym
    when :notice then "flash-notice"
    when :alert then "flash-alert"
    when :error then "flash-error"
    else "flash-info"
    end
  end
end
