# Create logger that ignores messages containing “CACHE”
class CacheFreeLogger < ActiveSupport::Logger
  def add(severity, message = nil, progname = nil, &block)
    return true if progname&.include? "CACHE"

    super
  end
end

# Overwrite ActiveRecord’s logger
ActiveRecord::Base.logger = CacheFreeLogger.new(STDOUT) if Rails.env.development?
