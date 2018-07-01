module ScheduleHelper

  # Get all events as a hash (including their break ids)
  def events_as_hash(events)
    events.map do |event|
      # don't show group events on a user's schedule, even if they made it?
      if @group or (@user and !event.group)
        event.attributes.merge(break_ids: event.repeat_exception_ids)
      end
    end
  end

  # Returns all categories + their break ids as a hash
  def categories_as_hash(categories)
    categories.map { |cat| cat.attributes.merge(break_ids: cat.repeat_exception_ids) }
  end
end