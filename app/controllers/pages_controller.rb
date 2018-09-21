require 'tasky'

class PagesController < ApplicationController
  before_action :authorize_admin!, only: [:admin, :sandbox]

  def admin #admin page
    @now = Time.zone.now
    @past = @now - 1.months
    
    @past_month_users = User.where('created_at >= ?', Time.zone.now - 1.months).group(:created_at).count
    @past_month_events = Event.where('created_at >= ?', Time.zone.now - 1.months).group(:created_at).count
    @past_month_events_modified = Event.where('created_at >= ?', Time.zone.now - 1.months).group(:updated_at).count
  end

  # Runs predefined server commands requested from the admin panel.
  def run_command
    cmd = case params[:button_id]
          when "run-jsdoc"               then "npm run jsdoc --silent"
          when "run-js-unit-tests"       then "npm run teaspoon --silent"
          when "run-js-acceptance-tests" then "rails test:system RAILS_ENV=test"
          when "run-rails-unit-tests"    then "rails test RAILS_ENV=test"
          end

    task_id = Tasky::run cmd
    render json: params.merge(task_id: task_id)
  rescue Tasky::CommandError => e
    render json: params.merge(cmd_error: e.inspect)
  end

  def check_if_command_is_finished
    task = Tasky::fetch_task params[:task_id]

    if task.finished?
      render json: {log: (task.success? ? "SUCCESS" : task.error_log)}
    else
      render json: {check_again: true}
    end
  end
end
