module ScheduleHelper
  def events_as_hash(events)
    events.map { |event| event.attributes.merge(break_ids: event.repeat_exception_ids) }
  end

  def categories_as_hash(categories)
    categories.map { |cat| cat.attributes.merge(break_ids: cat.repeat_exception_ids) }
  end
end