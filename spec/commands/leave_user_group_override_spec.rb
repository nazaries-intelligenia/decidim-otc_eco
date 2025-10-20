# frozen_string_literal: true

require "rails_helper"

RSpec.describe Decidim::LeaveUserGroup do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:user_group) { create(:user_group, organization: organization) }

  subject { described_class.new(user, user_group) }

  describe "#call (override behavior)" do
    context "when membership is missing" do
      it "broadcasts :invalid and does not change memberships" do
        Decidim::UserGroupMembership.delete_all

        expect { subject.call }.not_to change { Decidim::UserGroupMembership.count }
        expect(Decidim::ParticipatorySpacePrivateUser.exists?(user: user)).to be false
      end
    end

    context "when user is a member and assembly exists" do
      it "removes the membership and the participatory private user for that assembly" do
        # create membership
        Decidim::UserGroupMembership.create!(user: user, user_group: user_group, role: :member)

        # create an assembly for the user_group
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

        # create a participatory private user linking the user to the assembly
        Decidim::ParticipatorySpacePrivateUser.create!(user: user, privatable_to: assembly, published: true)

        expect(Decidim::UserGroupMembership.exists?(user: user, user_group: user_group)).to be true
        expect(Decidim::ParticipatorySpacePrivateUser.exists?(user: user, privatable_to: assembly)).to be true

        subject.call

        expect(Decidim::UserGroupMembership.exists?(user: user, user_group: user_group)).to be false
        expect(Decidim::ParticipatorySpacePrivateUser.exists?(user: user, privatable_to: assembly)).to be false
      end
    end

    context "when user is a member but no assembly exists" do
      it "removes the membership and does not error" do
        Decidim::UserGroupMembership.create!(user: user, user_group: user_group, role: :member)

        # ensure no assembly
        Decidim::Assembly.where(user_group: user_group).delete_all

        expect { subject.call }.to change { Decidim::UserGroupMembership.count }.by(-1)
        expect(Decidim::ParticipatorySpacePrivateUser.exists?(user: user)).to be false
      end
    end
  end
end

