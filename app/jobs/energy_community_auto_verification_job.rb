# frozen_string_literal: true

# Job to automatically verify/unverify a user's energy community membership
# This job is triggered when a user joins or leaves an energy community (user group)
#
class EnergyCommunityAutoVerificationJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = Decidim::User.find_by(id: user_id)
    return unless user

    SyncEnergyCommunityAuthorization.call(user)
  end
end
