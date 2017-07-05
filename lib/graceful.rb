module Graceful
  def self.time(time, default = "not available", format = "%Y-%m-%d at %H:%M")
    return default unless time.present?
    time.strftime format
  end
end