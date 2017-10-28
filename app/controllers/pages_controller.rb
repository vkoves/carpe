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

  # Used by run_command to keep track of command logs
  @@command_output_pipes = {}

  # Runs predefined server commands requested from the admin panel.
  def run_command
    cmd = case params[:button_id]
          when "run-jsdoc"               then "npm run jsdoc --silent"
          when "run-js-unit-tests"       then "npm run teaspoon --silent"
          when "run-js-acceptance-tests" then "npm run acceptance-tests --silent"
          when "run-rails-unit-tests"    then "npm run minitest --silent"
          end

    begin
      read, write = IO.pipe
      pid = Process.spawn cmd, out: File::NULL, err: write
    rescue StandardError => e
      render json: params.merge(cmd_error: e.inspect)
    else
      @@command_output_pipes[pid] = [read, write]
      render json: params.merge(pid: pid)
    end
  end

  def check_if_command_is_finished
    pid, status = Process.waitpid2 params[:pid].to_i, Process::WNOHANG

    if status.nil?
      render json: {check_again: true}
    else
      cmd_log, write = @@command_output_pipes.delete pid
      write.close
      render json: {log: (status.success? ? "SUCCESS" : cmd_log.read)}
    end
  end
end
