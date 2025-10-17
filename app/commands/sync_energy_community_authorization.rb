# frozen_string_literal: true

# Command to synchronize energy community authorization for a user
# This command updates or creates the authorization based on the user's current
# energy community memberships (user groups).
#
class SyncEnergyCommunityAuthorization < Decidim::Command
  # Public: Initializes the command.
  #
  # user - The user whose authorization needs to be synced
  def initialize(user)
    @user = user
  end

  # Executes the command. Broadcasts these events:
  #
  # - :ok when everything is valid.
  # - :invalid if we could not proceed.
  #
  # Returns nothing.
  def call
    return broadcast(:invalid) unless user

    if user_in_energy_communities?
      create_or_update_authorization
    else
      remove_authorization
    end

    broadcast(:ok)
  end

  private

  attr_reader :user

  def user_in_energy_communities?
    energy_community_ids.any?
  end

  def energy_community_ids
    @energy_community_ids ||= user.user_groups.pluck(:id)
  end

  def create_or_update_authorization
    authorization = Decidim::Authorization.find_or_initialize_by(
      user: user,
      name: "energy_community_member"
    )

    authorization.metadata = {
      "energy_community_ids" => energy_community_ids
    }
    authorization.granted_at = Time.current
    authorization.save!
  end

  def remove_authorization
    authorization = Decidim::Authorization.find_by(
      user: user,
      name: "energy_community_member"
    )

    authorization.destroy! if authorization
  end
end
