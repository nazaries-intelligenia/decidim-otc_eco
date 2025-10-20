# frozen_string_literal: true

require "rails_helper"

RSpec.describe Decidim::AcceptUserGroupJoinRequest do
  subject { described_class.new(membership) }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:user_group) { create(:user_group, organization: organization) }

  let!(:membership) { Decidim::UserGroupMembership.create!(user: user, user_group: user_group, role: :requested) }

  describe "#call (override behavior)" do
    context "when membership role is not requested" do
      it "does not accept and does not create private user" do
        membership.update!(role: :member)

        expect { subject.call }.not_to(change(Decidim::ParticipatorySpacePrivateUser, :count))
        # membership role should remain as member
        expect(membership.reload.role.to_s).to eq("member")
      end
    end

    context "when membership is requested" do
      it "accepts the membership and creates a participatory private user if assembly exists" do
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

        expect(Decidim::ParticipatorySpacePrivateUser.exists?(user: user, privatable_to: assembly)).to be false

        subject.call

        expect(membership.reload.role.to_s).to eq("member")

        pspu = Decidim::ParticipatorySpacePrivateUser.find_by(user: user, privatable_to: assembly)
        expect(pspu).not_to be_nil
        expect(pspu.published).to be true
      end

      it "accepts the membership but does not create private user if there is no assembly" do
        Decidim::Assembly.where(user_group: user_group).delete_all

        subject.call

        expect(membership.reload.role.to_s).to eq("member")
        expect(Decidim::ParticipatorySpacePrivateUser.exists?(user: user)).to be false
      end
    end
  end
end
