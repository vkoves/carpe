module GroupsHelper
  def can_manage_members?
    allow [:owner, :moderator]
  end

  def can_invite_members?
    allow [:owner, :moderator]
  end

  def can_edit_group?
    allow [:owner]
  end

  private

  def allow(roles)
    roles.include? @role
  end
end
