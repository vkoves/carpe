module ScheduleHelper
  def event_invite_roles
    EventInvite.roles.keys.map { |role| [role.humanize, role] }
  end
end
