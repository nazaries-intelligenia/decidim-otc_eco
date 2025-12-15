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
      current_user: user,
      address: "Street 123, 12345 City, Country",
      latitude: 1.234567,
      longitude: 2.345678,
      ec_agents: "EC Agents",
      has_installations: true,
      installations: [
        { "location" => "Building A, Main Roof", "power" => "50" },
        { "location" => "Building B, Secondary Roof", "power" => "50" }
      ],
      legal_form: "Cooperative",
      creation_date: Time.zone.today,
      action_types: "Thermal Renewables",
      financial_support: "20",
      project_website: "https://example.com",
      contact_person: "John Doe",
      privacy_policy_accepted: true
    )
  end

  # Disable geocoding callback for tests
  before do
    allow_any_instance_of(Decidim::UserGroup).to receive(:geocode) # rubocop:disable RSpec/AnyInstance
  end

  describe "#call (override behavior)" do
    before do
      subject.call
    end

    it "creates a user group with extended_data" do
      ug = Decidim::UserGroup.find_by(email: "group@example.com")
      expect(ug).not_to be_nil
      expect(ug.extended_data).to be_present
      expect(ug.extended_data["phone"]).to eq("+34123456")
      expect(ug.extended_data["verified_at"]).not_to be_nil
      expect(ug.extended_data["rejected_at"]).to be_nil
      expect(ug.extended_data["ec_agents"]).to eq("EC Agents")
      expect(ug.extended_data["has_installations"]).to be true
      expect(ug.extended_data["installations"]).to be_an(Array)
      expect(ug.extended_data["installations"].length).to eq(2)
      expect(ug.extended_data["installations"][0]["location"]).to eq("Building A, Main Roof")
      expect(ug.extended_data["installations"][0]["power"]).to eq("50")
      expect(ug.extended_data["installations"][1]["location"]).to eq("Building B, Secondary Roof")
      expect(ug.extended_data["installations"][1]["power"]).to eq("50")
      expect(ug.extended_data["legal_form"]).to eq("Cooperative")
      expect(ug.extended_data["creation_date"]).to eq(form.creation_date.to_s)
      expect(ug.extended_data["action_types"]).to eq("Thermal Renewables")
      expect(ug.extended_data["financial_support"]).to eq("20")
      expect(ug.extended_data["project_website"]).to eq("https://example.com")
      expect(ug.extended_data["contact_person"]).to eq("John Doe")
      expect(ug.extended_data["privacy_policy_accepted"]).to be true
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

    it "creates 8 initial debates in the debates component" do
      ug = Decidim::UserGroup.find_by(email: "group@example.com")
      assembly = Decidim::Assembly.find_by(user_group: ug)
      component = Decidim::Component.find_by(participatory_space: assembly, manifest_name: :debates)

      debates = Decidim::Debates::Debate.where(component: component)
      expect(debates.count).to eq(8)

      # Verify all debates have the user_group as author
      debates.each do |debate|
        expect(debate.author).to eq(ug)
        expect(debate.title).to be_present
        expect(debate.start_time).to be_nil
        expect(debate.end_time).to be_nil
      end
    end

    it "creates debates with correct translated titles" do
      ug = Decidim::UserGroup.find_by(email: "group@example.com")
      assembly = Decidim::Assembly.find_by(user_group: ug)
      component = Decidim::Component.find_by(participatory_space: assembly, manifest_name: :debates)

      debate_keys = [
        :steering_committee,
        :community_notices,
        :driving_group,
        :projects_financing,
        :community_dynamization,
        :alliances_sustainability,
        :improvement_suggestions,
        :energy_saving
      ]

      debates = Decidim::Debates::Debate.where(component: component)

      # Verify each specific debate key exists with correct translations
      debate_keys.each do |key|
        I18n.available_locales.each do |locale|
          expected_title = I18n.t("decidim.components.debates.initial_debates.titles.#{key}", locale: locale)
          debate_with_title = debates.find { |d| d.title[locale.to_s] == expected_title }
          expect(debate_with_title).not_to be_nil, "Expected to find debate with title '#{expected_title}' in locale '#{locale}'"
        end
      end
    end

    it "adds the group's users as private users to the assembly" do
      ug = Decidim::UserGroup.find_by(email: "group@example.com")
      assembly = Decidim::Assembly.find_by(user_group: ug)

      # the creator should have been added as a member and thus as a private user
      expect(Decidim::ParticipatorySpacePrivateUser.exists?(user: user, privatable_to: assembly, published: true)).to be true
    end
  end
end
