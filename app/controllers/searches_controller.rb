require "search_scoring"

class SearchesController < ApplicationController
  before_action :authorize_signed_in!
  before_action :setup_search
  respond_to :json

  # searches users and groups by name
  def all
    # Grab first five matching users
    @users = User.where("LOWER(name) LIKE ?", "%#{@query}%").limit(5)

    # Grab first five matching groups
    @groups = Group.where.not(privacy: :secret_group)
                   .where("LOWER(name) LIKE ?", "%#{@query}%").limit(5)

    # Sort the users and groups together
    @users_and_groups = (@users + @groups)
                          .sort_by { |item| SearchScore.name(item.name, @query) }
  end

  # searches all users by name
  def users
    matches = User.where("LOWER(name) LIKE ?", "%#{@query}%").limit(10)
    @users = matches.sort_by { |user| SearchScore.name(user.name, @query) }

    render "users"
  end

  # searches for users not already members in the given group
  def group_invitable_users
    group = Group.find(params[:group_id])
    @users = User.where("LOWER(name) LIKE ?", "%#{@query}%")
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
