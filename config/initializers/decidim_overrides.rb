# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Permissions.include(Decidim::PermissionsOverride)
  Decidim::ProfileActionsCell.include(Decidim::ProfileActionsCellOverride)
  Decidim::UserGroup.include(Decidim::UserGroupOverride)
  Decidim::Assembly.include(Decidim::AssemblyOverride)
  Decidim::CreateUserGroup.include(Decidim::CreateUserGroupOverride)
  Decidim::AcceptUserGroupJoinRequest.include(Decidim::AcceptUserGroupJoinRequestOverride)
  Decidim::AcceptGroupInvitation.include(Decidim::AcceptGroupInvitationOverride)
  Decidim::LeaveUserGroup.include(Decidim::LeaveUserGroupOverride)
  Decidim::RemoveUserFromGroup.include(Decidim::RemoveUserFromGroupOverride)
  Decidim::UserGroupForm.include(Decidim::UserGroupFormOverride)
  Decidim::GroupsCell.include(Decidim::GroupsCellOverride)
  Decidim::UpdateUserGroup.include(Decidim::UpdateUserGroupOverride)
  Decidim::UserGroupMembership.include(Decidim::UserGroupMembershipOverride)
end
