# frozen_string_literal: true

require "rails_helper"

RSpec.describe Decidim::LeaveUserGroup do
  subject { described_class.new(user, user_group) }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:user_group) { create(:user_group, organization: organization) }

  describe "#call (override behavior)" do
    context "when membership is missing" do
      it "broadcasts :invalid and does not change memberships" do
        Decidim::UserGroupMembership.delete_all

        expect { subject.call }.not_to(change(Decidim::UserGroupMembership, :count))
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

        expect { subject.call }.to change(Decidim::UserGroupMembership, :count).by(-1)
        expect(Decidim::ParticipatorySpacePrivateUser.exists?(user: user)).to be false
      end
    end

    context "when user is an admin and leaves the group" do
      it "removes the membership, the participatory private user, and the assembly admin role" do
        # create admin membership for the user that will leave
        Decidim::UserGroupMembership.create!(user: user, user_group: user_group, role: :admin)

        # create another admin so the leaving user is not the last admin
        another_admin = create(:user, :confirmed, organization: organization)
        Decidim::UserGroupMembership.create!(user: another_admin, user_group: user_group, role: :admin)

        # create an assembly for the user_group
        assembly = Decidim::Assembly.create!(
          title: { "en" => "Assembly" },
          subtitle: { "en" => "Subtitle" },
          short_description: { "en" => "Short" },
          description: { "en" => "Description" },
          slug: "agroup-admin",
          private_space: true,
          is_transparent: false,
          user_group: user_group,
          decidim_organization_id: organization.id
        )

        # create a participatory private user
        Decidim::ParticipatorySpacePrivateUser.create!(user: user, privatable_to: assembly, published: true)

        # create an assembly admin role
        Decidim::AssemblyUserRole.create!(user: user, assembly: assembly, role: "admin")

        expect(Decidim::UserGroupMembership.exists?(user: user, user_group: user_group)).to be true
        expect(Decidim::ParticipatorySpacePrivateUser.exists?(user: user, privatable_to: assembly)).to be true
        expect(Decidim::AssemblyUserRole.exists?(user: user, assembly: assembly, role: "admin")).to be true

        subject.call

        expect(Decidim::UserGroupMembership.exists?(user: user, user_group: user_group)).to be false
        expect(Decidim::ParticipatorySpacePrivateUser.exists?(user: user, privatable_to: assembly)).to be false
        expect(Decidim::AssemblyUserRole.exists?(user: user, assembly: assembly, role: "admin")).to be false
      end
    end
  end
end
