require 'overridden_helpers'
require 'utilities'

module ApplicationHelper
  include OverriddenHelpers
  include Utilities

  # Note: the given time is automatically cast to the user's preferred time zone.
  def relative_time_tag(to_time, start_caps = false)
    local_time = to_time.in_time_zone(current_user&.home_time_zone || "UTC")

    format = relative_time(to_time)
    format = format[0].upcase + format[1...format.size] if start_caps

    time_tag local_time, local_time.strftime(format)
  end

  def relative_event_time_tag(event)
    start_tense = event.date.past? ? "Started" : "Starting"
    end_tense = event.end_date.past? ? "ended" : "ends"
    start_time = relative_time_tag event.date
    end_time = relative_time_tag event.end_date

    "#{start_tense} #{start_time}, #{end_tense} #{end_time}".html_safe
  end

  def link_to_block(name = nil, options = nil, html_options = nil)
    link_to(options, html_options) do
      content_tag :span, name
    end
  end

  # Adds :size parameter to html_options. This is the size of the image
  # being requested.
  def link_avatar(options, html_options = {})
    html_options.merge!(class: " avatar") { |_, old, new| old + new }
    url = options.avatar_url(html_options[:size] || 256)

    link_to options, html_options do
      image_tag url
    end
  end

  def validation_error_messages!(resource)
    return "" if resource.errors.empty?

    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t("errors.messages.not_saved",
                      count: resource.errors.count,
                      resource: resource.class.model_name.name)

    <<-HTML.html_safe
    <div id="error_explanation">
      <h2>#{sentence}</h2>
      <ul>#{messages}</ul>
    </div>
    HTML
  end
end
