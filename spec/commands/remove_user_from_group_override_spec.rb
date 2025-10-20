# frozen_string_literal: true

require "rails_helper"

RSpec.describe Decidim::RemoveUserFromGroup do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:user_group) { create(:user_group, organization: organization) }
  let(:other_group) { create(:user_group, organization: organization) }

  subject { described_class.new(membership, user_group) }

  describe "#call (override behavior)" do
    context "when membership is missing" do
      let(:membership) { nil }

      it "broadcasts :invalid and does not change memberships" do
        Decidim::UserGroupMembership.delete_all

        expect { subject.call }.not_to change(Decidim::UserGroupMembership, :count)
        expect(Decidim::ParticipatorySpacePrivateUser.exists?(user: user)).to be false
      end
    end

    context "when membership belongs to another group" do
      let!(:membership) { Decidim::UserGroupMembership.create!(user: user, user_group: other_group, role: :member) }

      it "broadcasts :invalid and does not remove it" do
        expect { subject.call }.not_to change(Decidim::UserGroupMembership, :count)
        expect(Decidim::UserGroupMembership.exists?(user: user, user_group: other_group)).to be true
      end
    end

    context "when membership exists and assembly exists" do
      let!(:membership) { Decidim::UserGroupMembership.create!(user: user, user_group: user_group, role: :member) }

      it "removes the membership and the participatory private user for that assembly" do
        assembly = Decidim::Assembly.create!(
          title: { "en" => "Assembly" },
          subtitle: { "en" => "Subtitle" },
          short_description: { "en" => "Short" },
          description: { "en" => "Description" },
          slug: "agroup",
          private_space: true,
          is_transparent: false,
          user_group: user_group,
          decidim_organization_id: organization.id
        )

        Decidim::ParticipatorySpacePrivateUser.create!(user: user, privatable_to: assembly, published: true)

        expect(Decidim::UserGroupMembership.exists?(user: user, user_group: user_group)).to be true
        expect(Decidim::ParticipatorySpacePrivateUser.exists?(user: user, privatable_to: assembly)).to be true

        subject.call

        expect(Decidim::UserGroupMembership.exists?(user: user, user_group: user_group)).to be false
        expect(Decidim::ParticipatorySpacePrivateUser.exists?(user: user, privatable_to: assembly)).to be false
      end
    end

    context "when membership exists but no assembly" do
      let!(:membership) { Decidim::UserGroupMembership.create!(user: user, user_group: user_group, role: :member) }

      it "removes only the membership" do
        Decidim::Assembly.where(user_group: user_group).delete_all

        expect { described_class.new(membership, user_group).call }.to change { Decidim::UserGroupMembership.count }.by(-1)
        expect(Decidim::ParticipatorySpacePrivateUser.exists?(user: user)).to be false
      end
    end
  end
end
