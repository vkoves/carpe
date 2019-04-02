module ScheduleHelper
  def event_invite_roles
    EventInvite.roles.keys.map { |role| [role.humanize, role] }
  end

  def show_event_invite_delete?(event_invite)
    has_permission = can? :destroy, event_invite
    is_host = (event_invite.user == event_invite.host_event.creator)

    has_permission && !is_host
  end
end
