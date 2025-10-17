# frozen_string_literal: true

require "rails_helper"

# Test that verifies automatic authorization when users join or leave energy communities
RSpec.describe "Energy community authorization" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:admin_user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:energy_community) { create(:user_group, organization: organization) }

  describe "automatic authorization on membership changes" do
    context "when a user joins an energy community" do
      it "creates an authorization with the energy community ID" do
        # User has no authorization initially
        expect(Decidim::Authorization.find_by(user: user, name: "energy_community_member")).to be_nil

        # Create membership and accept it
        membership = create(:user_group_membership, user: user, user_group: energy_community, role: "requested")
        membership.update!(role: "member")

        # Process background jobs
        perform_enqueued_jobs

        # Authorization should be created
        authorization = Decidim::Authorization.find_by(user: user, name: "energy_community_member")
        expect(authorization).to be_present
        expect(authorization.metadata["energy_community_ids"]).to include(energy_community.id)
        expect(authorization.granted_at).to be_present
      end
    end

    context "when a user belongs to multiple energy communities" do
      let(:energy_community_two) { create(:user_group, organization: organization) }

      it "updates authorization with all energy community IDs" do
        # User joins first community
        create(:user_group_membership, user: user, user_group: energy_community, role: "member")
        perform_enqueued_jobs

        # User joins second community
        membership2 = create(:user_group_membership, user: user, user_group: energy_community_two, role: "requested")
        membership2.update!(role: "member")
        perform_enqueued_jobs

        # Authorization should include both communities
        authorization = Decidim::Authorization.find_by(user: user, name: "energy_community_member")
        expect(authorization).to be_present
        expect(authorization.metadata["energy_community_ids"]).to contain_exactly(energy_community.id, energy_community_two.id)
      end
    end

    context "when a user leaves an energy community" do
      let!(:membership) { create(:user_group_membership, user: user, user_group: energy_community, role: "member") }
      let!(:authorization) do
        create(
          :authorization,
          user: user,
          name: "energy_community_member",
          metadata: { "energy_community_ids" => [energy_community.id] }
        )
      end

      it "removes the authorization" do
        expect(Decidim::Authorization.find_by(user: user, name: "energy_community_member")).to be_present

        # User leaves the community
        membership.destroy!
        perform_enqueued_jobs

        # Authorization should be removed
        expect(Decidim::Authorization.find_by(user: user, name: "energy_community_member")).to be_nil
      end
    end

    context "when a user leaves one community but remains in another" do
      let(:energy_community_two) { create(:user_group, organization: organization) }
      let!(:membership1) { create(:user_group_membership, user: user, user_group: energy_community, role: "member") }
      let!(:membership2) { create(:user_group_membership, user: user, user_group: energy_community_two, role: "member") }
      let!(:authorization) do
        create(
          :authorization,
          user: user,
          name: "energy_community_member",
          metadata: { "energy_community_ids" => [energy_community.id, energy_community_two.id] }
        )
      end

      it "updates authorization removing only the left community" do
        # User leaves first community
        membership1.destroy!
        perform_enqueued_jobs

        # Authorization should be updated, not removed
        authorization.reload
        expect(authorization).to be_present
        expect(authorization.metadata["energy_community_ids"]).to eq([energy_community_two.id])
        expect(authorization.metadata["energy_community_ids"]).not_to include(energy_community.id)
      end
    end

    context "when a membership is created but not yet accepted" do
      it "does not create authorization until membership is accepted" do
        # Create membership in requested state
        membership = create(:user_group_membership, user: user, user_group: energy_community, role: "requested")
        perform_enqueued_jobs

        # No authorization should be created yet
        expect(Decidim::Authorization.find_by(user: user, name: "energy_community_member")).to be_nil

        # Accept the membership
        membership.update!(role: "member")
        perform_enqueued_jobs

        # Now authorization should exist
        authorization = Decidim::Authorization.find_by(user: user, name: "energy_community_member")
        expect(authorization).to be_present
      end
    end
  end
end
