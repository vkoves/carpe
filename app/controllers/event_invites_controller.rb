class EventInvitesController < ApplicationController
  before_action :set_event_invite, only: [:show, :edit, :update, :destroy]

  # GET /event_invites
  # GET /event_invites.json
  def index
    @event_invites = EventInvite.all
  end

  def invite_multiple_users

  end

  # GET /event_invites/1
  # GET /event_invites/1.json
  def show
  end

  # GET /event_invites/new
  def new
    @event_invite = EventInvite.new
  end

  # GET /event_invites/1/edit
  def edit
  end

  # POST /event_invites
  # POST /event_invites.json
  def create
    recipients = User.find(params[:user_ids].split(","))
    event = Event.find(params[:event_id])

    invites = recipients.map do |recipient|
      EventInvite.create({
          sender_id: current_user.id,
          recipient_id: recipient.id,
          event_id: event.id
      })
    end

    if invites.all?(&:save)
      render invites
    else
      error_msg = invites.map{ |inv| inv.errors.messages.values }.join(", ")
      render plain: error_msg, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /event_invites/1
  # PATCH/PUT /event_invites/1.json
  def update
    respond_to do |format|
      if @event_invite.update(event_invite_params)
        format.html { redirect_to @event_invite, notice: 'Event invite was successfully updated.' }
        format.json { render :show, status: :ok, location: @event_invite }
      else
        format.html { render :edit }
        format.json { render json: @event_invite.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /event_invites/1
  # DELETE /event_invites/1.json
  def destroy
    @event_invite.destroy
    respond_to do |format|
      format.html { redirect_to event_invites_url, notice: 'Event invite was successfully destroyed.' }
      format.json { head :no_content }
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event_invite
      @event_invite = EventInvite.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_invite_params
      params.require(:event_invite).permit(:role, :status, :sender_id, :event_id, :recipient_id)
    end
end
