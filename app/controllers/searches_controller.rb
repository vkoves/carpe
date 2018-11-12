require 'search_scoring'

class SearchesController < ApplicationController
  before_action :authorize_signed_in!
  before_action :setup_search
  respond_to :json

  # searches users and groups by name
  def all
    @users = User.where('LOWER(name) LIKE ?', "%#{@query}%").limit(5)
                 .sort_by { |user| SearchScore.name(user.name, @query) }

    @groups = Group.where.not(privacy: :secret_group)
                   .where('LOWER(name) LIKE ?', "%#{@query}%").limit(5)
                   .sort_by { |user| SearchScore.name(user.name, @query) }

    @users_and_groups = @users + @groups
  end

  # searches all users by name
  def users
    matches = User.where('LOWER(name) LIKE ?', "%#{@query}%").limit(10)
    @users = matches.sort_by { |user| SearchScore.name(user.name, @query) }

    render "users"
  end

  # searches for users not already members in the given group
  def group_invitable_users
    group = Group.find(params[:group_id])
    @users = User.where('LOWER(name) LIKE ?', "%#{@query}%")
                 .where.not(id: group.members).limit(10)
                 .sort_by { |user| SearchScore.name(user.name, @query) }

    render "users"
  end

  private

  def setup_search
    @query = params[:q].strip.downcase
    render json: [] if @query.blank?
  end
end
