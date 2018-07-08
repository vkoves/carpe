# Create logger that ignores messages containing “CACHE”
class CacheFreeLogger < ActiveSupport::Logger
  def add(severity, message = nil, progname = nil, &block)
    return true if progname&.include? "CACHE"
    super
  end
end

# Overwrite ActiveRecord’s logger
if Rails.env.development?
  ActiveRecord::Base.logger = CacheFreeLogger.new(STDOUT)
end