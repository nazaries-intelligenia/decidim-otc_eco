# frozen_string_literal: true

require "rails_helper"

RSpec.describe Decidim::UserGroupMembership do
  let(:organization) { create(:organization) }
  let(:user_group) { create(:user_group, organization: organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }
  let(:assembly) do
    create(:assembly, organization: organization, private_space: true).tap do |a|
      user_group.update!(assembly: a)
    end
  end

  describe "sync_admin_role_with_assembly callback" do
    context "when a member is promoted to admin" do
      let!(:membership) do
        create(:user_group_membership, user: user, user_group: user_group, role: "member")
      end

      before { assembly } # Ensure assembly exists

      it "creates an AssemblyUserRole with admin role" do
        expect do
          membership.update!(role: "admin")
        end.to change(Decidim::AssemblyUserRole, :count).by(1)

        assembly_role = Decidim::AssemblyUserRole.find_by(
          user: user,
          assembly: assembly,
          role: "admin"
        )
        expect(assembly_role).to be_present
      end

      it "does not create duplicate AssemblyUserRole if already exists" do
        # Crear el rol de asamblea manualmente
        Decidim::AssemblyUserRole.create!(
          user: user,
          assembly: assembly,
          role: "admin"
        )

        expect do
          membership.update!(role: "admin")
        end.not_to change(Decidim::AssemblyUserRole, :count)
      end
    end

    context "when an admin is demoted to member" do
      let!(:membership) do
        create(:user_group_membership, user: user, user_group: user_group, role: "admin")
      end

      let!(:assembly_role) do
        assembly # Ensure assembly exists
        Decidim::AssemblyUserRole.create!(
          user: user,
          assembly: assembly,
          role: "admin"
        )
      end

      it "removes the AssemblyUserRole" do
        expect do
          membership.update!(role: "member")
        end.to change(Decidim::AssemblyUserRole, :count).by(-1)

        expect(Decidim::AssemblyUserRole.exists?(assembly_role.id)).to be false
      end
    end

    context "when user_group has no assembly" do
      let(:user_group_without_assembly) { create(:user_group, organization: organization) }
      let!(:membership) do
        create(:user_group_membership, user: user, user_group: user_group_without_assembly, role: "member")
      end

      it "does not create an AssemblyUserRole" do
        expect do
          membership.update!(role: "admin")
        end.not_to change(Decidim::AssemblyUserRole, :count)
      end
    end

    context "when multiple admins exist" do
      let(:user2) { create(:user, :confirmed, organization: organization) }
      let!(:membership1) do
        create(:user_group_membership, user: user, user_group: user_group, role: "admin")
      end
      let!(:membership2) do
        create(:user_group_membership, user: user2, user_group: user_group, role: "member")
      end

      before do
        assembly # Ensure assembly exists
        Decidim::AssemblyUserRole.create!(
          user: user,
          assembly: assembly,
          role: "admin"
        )
      end

      it "promotes second user to admin independently" do
        expect do
          membership2.update!(role: "admin")
        end.to change(Decidim::AssemblyUserRole, :count).by(1)

        expect(Decidim::AssemblyUserRole.where(assembly: assembly, role: "admin").count).to eq(2)
      end
    end
  end
end
