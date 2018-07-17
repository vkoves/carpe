require 'search_scoring'

class SearchController < ApplicationController
  before_action :authorize_signed_in!
  before_action :setup_search
  respond_to :json

  # searches users and groups by name
  def all
    matches = User.where('LOWER(name) LIKE ?', "%#{@query}%").limit(10)
    @users = matches.sort_by{ |user| SearchScore.by_name(user.name, @query) }

    # TODO: search groups as well
  end

  # searches all users by name
  def users
    matches = User.where('LOWER(name) LIKE ?', "%#{@query}%").limit(10)
    @users = matches.sort_by{ |user| SearchScore.by_name(user.name, @query) }
  end

  # searches all users by name who are not already participating in the given event
  def event_invite_participants
    participants = EventInvite.where(event_id: params[:event_id]).pluck(:recipient_id)
    matches = User.where('LOWER(name) LIKE ?', "%#{@query}%")
                      .where.not(id: participants).limit(10)
    @users = matches.sort_by{ |user| SearchScore.by_name(user.name, @query) }
  end

  private

  def setup_search
    @query = params[:q].strip.downcase
    render json: {} if @query.blank?
  end
end
