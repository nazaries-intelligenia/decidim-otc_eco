# frozen_string_literal: true

require "rails_helper"

RSpec.describe Decidim::UpdateUserGroup do
  subject { described_class.new(form, user_group) }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }

  let!(:user_group) do
    allow_any_instance_of(Decidim::UserGroup).to receive(:geocode) # rubocop:disable RSpec/AnyInstance
    create(
      :user_group,
      email: "old@example.com",
      name: "Old Energy Community",
      nickname: "old_community",
      organization: organization,
      about: "Old about",
      phone: "+34111111",
      address: "Old Street 1",
      latitude: 0.123456,
      longitude: 0.654321,
      extended_data: {
        ec_agents: "Old EC Agents",
        installed_power: "50",
        legal_form: "Association",
        creation_date: 1.year.ago.to_date.to_s,
        assistance: "Old Assistance",
        action_types: "Solar",
        financial_support: "10",
        project_website: "https://old.example.com",
        contact_person: "Jane Doe",
        phone: "+34111111",
        privacy_policy_accepted: false,
        privacy_policy_accepted_at: nil
      }
    )
  end

  let(:form) do
    double(
      "form",
      invalid?: false,
      email: "new@example.com",
      name: "New Energy Community",
      nickname: "new_community",
      current_organization: organization,
      about: "New about the group",
      avatar: nil,
      phone: "+34987654321",
      current_user: user,
      address: "New Street 456, 54321 City, Country",
      latitude: 1.234567,
      longitude: 2.345678,
      ec_agents: "New EC Agents",
      installed_power: "200",
      legal_form: "Cooperative",
      creation_date: Time.zone.today,
      assistance: "New Assistance",
      action_types: "Wind Renewables",
      financial_support: "50",
      project_website: "https://new.example.com",
      contact_person: "John Smith",
      privacy_policy_accepted: true
    )
  end

  before do
    allow_any_instance_of(Decidim::UserGroup).to receive(:geocode) # rubocop:disable RSpec/AnyInstance
  end

  describe "#call (override behavior)" do
    before do
      subject.call
      user_group.reload
    end

    it "updates basic user group attributes" do
      expect(user_group.name).to eq("New Energy Community")
      expect(user_group.about).to eq("New about the group")
      expect(user_group.address).to eq("New Street 456, 54321 City, Country")
      expect(user_group.latitude).to eq(1.234567)
      expect(user_group.longitude).to eq(2.345678)
    end

    it "updates extended_data fields" do
      expect(user_group.extended_data).to be_present
      expect(user_group.extended_data["phone"]).to eq("+34987654321")
      expect(user_group.extended_data["ec_agents"]).to eq("New EC Agents")
      expect(user_group.extended_data["installed_power"]).to eq("200")
      expect(user_group.extended_data["legal_form"]).to eq("Cooperative")
      expect(user_group.extended_data["creation_date"]).to eq(Time.zone.today.to_s)
      expect(user_group.extended_data["assistance"]).to eq("New Assistance")
      expect(user_group.extended_data["action_types"]).to eq("Wind Renewables")
      expect(user_group.extended_data["financial_support"]).to eq("50")
      expect(user_group.extended_data["project_website"]).to eq("https://new.example.com")
      expect(user_group.extended_data["contact_person"]).to eq("John Smith")
    end

    it "updates privacy_policy_accepted to true and sets timestamp" do
      expect(user_group.extended_data["privacy_policy_accepted"]).to be true
      expect(user_group.extended_data["privacy_policy_accepted_at"]).not_to be_nil
      expect(user_group.extended_data["privacy_policy_accepted_at"]).to be_a(String)
    end

    context "when privacy_policy_accepted is false" do
      let(:form) do
        double(
          "form",
          invalid?: false,
          email: "new@example.com",
          name: "New Energy Community",
          nickname: "new_community",
          current_organization: organization,
          about: "New about the group",
          avatar: nil,
          phone: "+34987654321",
          current_user: user,
          address: "New Street 456, 54321 City, Country",
          latitude: 1.234567,
          longitude: 2.345678,
          ec_agents: "New EC Agents",
          installed_power: "200",
          legal_form: "Cooperative",
          creation_date: Time.zone.today,
          assistance: "New Assistance",
          action_types: "Wind Renewables",
          financial_support: "50",
          project_website: "https://new.example.com",
          contact_person: "John Smith",
          privacy_policy_accepted: false
        )
      end

      it "sets privacy_policy_accepted_at to nil" do
        expect(user_group.extended_data["privacy_policy_accepted"]).to be false
        expect(user_group.extended_data["privacy_policy_accepted_at"]).to be_nil
      end
    end

    context "when form is invalid" do
      let(:form) do
        double(
          "form",
          invalid?: true
        )
      end

      it "does not update the user group" do
        original_name = Decidim::UserGroup.find(user_group.id).name
        expect(original_name).to eq("Old Energy Community")
      end
    end
  end
end
