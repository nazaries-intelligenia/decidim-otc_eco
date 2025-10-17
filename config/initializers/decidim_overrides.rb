# frozen_string_literal: true

Rails.application.config.to_prepare do
  Decidim::Permissions.include(Decidim::PermissionsOverride)
  Decidim::ProfileActionsCell.include(Decidim::ProfileActionsCellOverride)
  Decidim::UserGroupMembership.include(Decidim::UserGroupMembershipOverride)
end
