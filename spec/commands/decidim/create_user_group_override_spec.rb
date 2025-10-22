# frozen_string_literal: true

require "rails_helper"

RSpec.describe Decidim::CreateUserGroup do
  subject { described_class.new(form) }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }

  # nickname starting with non-letter and containing underscore to exercise slug logic
  let(:nickname) { "_1bad_name" }

  let(:form) do
    double(
      "form",
      invalid?: false,
      email: "group@example.com",
      name: "Energy Community",
      nickname: nickname,
      current_organization: organization,
      about: "About the group",
      avatar: nil,
      phone: "+34123456",
      document_number: "ID-123",
      current_user: user,
      address: "Street 123, 12345 City, Country",
      latitude: 1.234567,
      longitude: 2.345678
    )
  end

  describe "#call (override behavior)" do
    before do
      subject.call
    end

    it "creates a user group with extended_data including verified_at and rejected_at nil" do
      ug = Decidim::UserGroup.find_by(email: "group@example.com")
      expect(ug).not_to be_nil
      expect(ug.extended_data).to be_present
      expect(ug.extended_data["phone"]).to eq("+34123456")
      expect(ug.extended_data["document_number"]).to eq("ID-123")
      expect(ug.extended_data["verified_at"]).not_to be_nil
      expect(ug.extended_data["rejected_at"]).to be_nil
    end

    it "creates a membership for the current user as creator" do
      ug = Decidim::UserGroup.find_by(email: "group@example.com")
      expect(Decidim::UserGroupMembership.exists?(user: user, user_group: ug, role: "creator")).to be true
    end

    it "creates a private assembly associated to the user group with a sanitized slug" do
      ug = Decidim::UserGroup.find_by(email: "group@example.com")
      assembly = Decidim::Assembly.find_by(user_group: ug)
      expect(assembly).not_to be_nil

      # nickname "_1bad_name" -> replace _ with - => "-1bad-name" -> prepend 'a' => "a-1bad-name" -> remove invalid chars (none)
      expect(assembly.slug).to eq("a-1bad-name")
      expect(assembly.private_space).to be(true)
      expect(assembly.is_transparent).to be(false)
    end

    it "creates a debates component for the assembly with comments enabled" do
      ug = Decidim::UserGroup.find_by(email: "group@example.com")
      assembly = Decidim::Assembly.find_by(user_group: ug)
      component = Decidim::Component.find_by(participatory_space: assembly, manifest_name: :debates)
      expect(component).not_to be_nil
      expect(component.name[organization.default_locale]).to eq("Foro")
      expect(component.settings["comments_enabled"]).to be true
    end

    it "creates a main_data content block for the assembly" do
      ug = Decidim::UserGroup.find_by(email: "group@example.com")
      assembly = Decidim::Assembly.find_by(user_group: ug)

      content_block = Decidim::ContentBlock.find_by(
        scoped_resource_id: assembly.id,
        manifest_name: "main_data",
        scope_name: "assembly_homepage"
      )

      expect(content_block).not_to be_nil
      expect(content_block.decidim_organization_id).to eq(organization.id)
      expect(content_block.published_at).not_to be_nil
      expect(content_block.weight).to eq(1)
    end

    it "adds the group's users as private users to the assembly" do
      ug = Decidim::UserGroup.find_by(email: "group@example.com")
      assembly = Decidim::Assembly.find_by(user_group: ug)

      # the creator should have been added as a member and thus as a private user
      expect(Decidim::ParticipatorySpacePrivateUser.exists?(user: user, privatable_to: assembly, published: true)).to be true
    end
  end
end
