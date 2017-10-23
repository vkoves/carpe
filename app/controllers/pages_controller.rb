class PagesController < ApplicationController
  before_action :authorize_admin,
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

  # runs a command based on a given admin panel button id
  # button id is passed via params[:button_id]
  def run_command
    cmd =
      case params[:button_id]
      when "run-jsdoc"               then "npm run jsdoc"
      when "run-js-unit-tests"       then "npm run teaspoon"
      when "run-js-acceptance-tests" then "npm run codeceptjs"
      when "run-rails-unit-tests"    then "bundle exec rails test"
      end

    pid = Process.spawn cmd
    Process.detach pid # prevents zombie processes
    render json: { button_id: params[:button_id], pid: pid }
  rescue
    render json: { button_id: params[:button_id], pid: pid, error: "true" }
  end

  # Checks if a command run on a given pid is complete
  # pid is grabbed from params[:pid]
  def check_if_command_is_finished
    # signal 0 checks if the processor exists
    Process.kill 0, params[:pid].to_i
    render json: { finished: "false" }
  rescue
    # (mostly likely) the process no longer exists
    render json: { finished: "true" }
  end
end
