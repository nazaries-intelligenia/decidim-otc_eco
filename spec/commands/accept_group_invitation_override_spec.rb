# frozen_string_literal: true

require "rails_helper"

RSpec.describe Decidim::AcceptGroupInvitation do
  let(:organization) { create(:organization) }
  let(:invited_user) { create(:user, :confirmed, organization: organization) }
  let(:creator_user) { create(:user, :confirmed, organization: organization) }
  let(:user_group) { create(:user_group, organization: organization) }

  before do
    # create an invited membership for invited_user
    Decidim::UserGroupMembership.create!(user: invited_user, user_group: user_group, role: :invited)
  end

  subject { described_class.new(user_group, invited_user) }

  describe "#call (override behavior)" do
    context "when membership is missing" do
      it "broadcasts :invalid" do
        # remove membership
        Decidim::UserGroupMembership.delete_all

        expect { subject.call }.not_to change { Decidim::UserGroupMembership.count }
        # the original command should not create any private users either
        expect(Decidim::ParticipatorySpacePrivateUser.exists?(user: invited_user)).to be false
      end
    end

    context "when membership exists" do
      it "accepts the invitation and adds the user as private user to the assembly when present" do
        # create an assembly associated to the user group
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

        # ensure no private user exists before
        expect(Decidim::ParticipatorySpacePrivateUser.exists?(user: invited_user, privatable_to: assembly)).to be false

        subject.call

        # membership role should be member
        membership = Decidim::UserGroupMembership.find_by(user: invited_user, user_group: user_group)
        expect(membership.role.to_s).to eq("member")

        # private user should be created and published
        pspu = Decidim::ParticipatorySpacePrivateUser.find_by(user: invited_user, privatable_to: assembly)
        expect(pspu).not_to be_nil
        expect(pspu.published).to be true
      end

      it "does not create a participatory private user if the user_group has no assembly" do
        # ensure user_group has no assembly
        Decidim::Assembly.where(user_group: user_group).delete_all

        subject.call

        # membership should be updated
        membership = Decidim::UserGroupMembership.find_by(user: invited_user, user_group: user_group)
        expect(membership.role.to_s).to eq("member")

        # no private user should be added
        expect(Decidim::ParticipatorySpacePrivateUser.exists?(user: invited_user)).to be false
      end
    end
  end
end
