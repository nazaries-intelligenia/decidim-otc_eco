# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Permissions.include(Decidim::PermissionsOverride)
  Decidim::ProfileActionsCell.include(Decidim::ProfileActionsCellOverride)
  Decidim::UserGroup.include(Decidim::UserGroupOverride)
  Decidim::CreateUserGroup.include(Decidim::CreateUserGroupOverride)
  Decidim::UserGroupForm.include(Decidim::UserGroupFormOverride)
  Decidim::GroupsCell.include(Decidim::GroupsCellOverride)
  Decidim::UserGroupPresenter.include(Decidim::UserGroupPresenterOverride)
end
