require 'tasky'

class PagesController < ApplicationController
  before_action :authorize_admin!,
                only: [:promote, :admin, :sandbox, :destroy_user, :admin_user_info]

  def promote # promote or demote users admin status
    @user = User.find(params[:id])
    @user.admin = (params[:de] != "true") # they're an admin if not being demoted
    @user.save

    render json: { action: "promote", uid: params[:id] }
  end

  def destroy_user
    user = User.from_param params[:id]
    user.destroy

    redirect_to "/admin"
  end

  def admin_user_info
    @user = User.from_param params[:id]
    @user_groups = UsersGroup.where(user_id: @user.id)
  end

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
          when "run-js-acceptance-tests" then "npm run acceptance-tests --silent"
          when "run-rails-unit-tests"    then "npm run minitest --silent"
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
