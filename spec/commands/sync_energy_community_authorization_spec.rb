# frozen_string_literal: true

require "rails_helper"

RSpec.describe SyncEnergyCommunityAuthorization do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:command) { described_class.new(user) }

  describe "#call" do
    context "when user is nil" do
      let(:user) { nil }

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "does not create any authorization" do
        expect { command.call }.not_to change(Decidim::Authorization, :count)
      end
    end

    context "when user has no energy communities (user groups)" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "does not create any authorization" do
        expect { command.call }.not_to change(Decidim::Authorization, :count)
      end

      context "and user already had an authorization" do
        let!(:authorization) do
          create(
            :authorization,
            user: user,
            name: "energy_community_member",
            metadata: { "energy_community_ids" => [123] }
          )
        end

        it "removes the existing authorization" do
          expect { command.call }.to change(Decidim::Authorization, :count).by(-1)
        end

        it "broadcasts ok" do
          expect { command.call }.to broadcast(:ok)
        end
      end
    end

    context "when user belongs to energy communities (user groups)" do
      let(:user_group_one) { create(:user_group, organization: organization) }
      let(:user_group_two) { create(:user_group, organization: organization) }

      before do
        create(:user_group_membership, user: user, user_group: user_group_one)
        create(:user_group_membership, user: user, user_group: user_group_two)
      end

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "creates a new authorization" do
        expect { command.call }.to change(Decidim::Authorization, :count).by(1)
      end

      it "creates authorization with correct name" do
        command.call
        authorization = Decidim::Authorization.find_by(user: user)
        expect(authorization.name).to eq("energy_community_member")
      end

      it "stores energy community IDs in metadata" do
        command.call
        authorization = Decidim::Authorization.find_by(user: user)
        expect(authorization.metadata["energy_community_ids"]).to contain_exactly(user_group_one.id, user_group_two.id)
      end

      it "sets granted_at timestamp" do
        command.call
        authorization = Decidim::Authorization.find_by(user: user)
        expect(authorization.granted_at).to be_present
        expect(authorization.granted_at).to be_within(1.second).of(Time.current)
      end

      context "when authorization already exists" do
        let(:user_group_three) { create(:user_group, organization: organization) }
        let!(:existing_authorization) do
          create(
            :authorization,
            user: user,
            name: "energy_community_member",
            metadata: { "energy_community_ids" => [999] },
            granted_at: 1.day.ago
          )
        end

        before do
          create(:user_group_membership, user: user, user_group: user_group_three)
        end

        it "does not create a new authorization" do
          expect { command.call }.not_to change(Decidim::Authorization, :count)
        end

        it "updates the existing authorization metadata" do
          command.call
          existing_authorization.reload
          expect(existing_authorization.metadata["energy_community_ids"]).to contain_exactly(user_group_one.id, user_group_two.id, user_group_three.id)
        end

        it "updates granted_at timestamp" do
          old_granted_at = existing_authorization.granted_at
          command.call
          existing_authorization.reload
          expect(existing_authorization.granted_at).to be > old_granted_at
          expect(existing_authorization.granted_at).to be_within(1.second).of(Time.current)
        end
      end
    end

    context "when user loses all energy community memberships" do
      let(:user_group) { create(:user_group, organization: organization) }
      let!(:authorization) do
        create(
          :authorization,
          user: user,
          name: "energy_community_member",
          metadata: { "energy_community_ids" => [user_group.id] }
        )
      end

      before do
        # Create membership first, then remove it
        membership = create(:user_group_membership, user: user, user_group: user_group)
        membership.destroy
      end

      it "removes the authorization" do
        expect { command.call }.to change(Decidim::Authorization, :count).by(-1)
      end

      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end
    end

    context "when user gains a new energy community membership" do
      let(:user_group_one) { create(:user_group, organization: organization) }
      let(:user_group_two) { create(:user_group, organization: organization) }
      let!(:authorization) do
        create(
          :authorization,
          user: user,
          name: "energy_community_member",
          metadata: { "energy_community_ids" => [user_group_one.id] }
        )
      end

      before do
        create(:user_group_membership, user: user, user_group: user_group_one)
        create(:user_group_membership, user: user, user_group: user_group_two)
      end

      it "updates authorization with new energy community IDs" do
        command.call
        authorization.reload
        expect(authorization.metadata["energy_community_ids"]).to contain_exactly(user_group_one.id, user_group_two.id)
      end

      it "does not create duplicate authorizations" do
        expect { command.call }.not_to change(Decidim::Authorization, :count)
      end
    end
  end
end
