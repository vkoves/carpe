class UsersGroup < ActiveRecord::Base
  enum role: { member: 0, admin: 1, owner: 2, editor: 3 }

  belongs_to :user
  belongs_to :group

  # This table explicitly maps out role permissions in groups.
  # For example, the owner can assign a member to be either
  # an editor or a moderator.
  # See the UsersGroup role enum for what roles are available.
  group_user_role_assignment_permissions = {
    owner: {
      member: [:editor, :moderator],
      editor: [:member, :moderator],
      moderator: [:member, :editor]
    },

    moderator: {
      member: [:editor],
      moderator: [:member]
    }
  }
end