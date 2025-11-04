# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User profile displays user type" do
  let(:organization) { create(:organization) }

  context "when user has a user_type" do
    let!(:user) do
      create(
        :user,
        :confirmed,
        organization: organization,
        name: "John Doe",
        nickname: "johndoe",
        extended_data: { "user_type" => "pyme" }
      )
    end

    before do
      switch_to_host(organization.host)
    end

    it "displays the user type on the public profile" do
      visit decidim.profile_path(user.nickname)

      expect(page).to have_content("John Doe")
      expect(page).to have_content("SME")
      expect(page).to have_css(".profile__details-user-type")
    end

    it "displays different user types correctly" do
      user_types = {
        "individual" => "Individual",
        "pyme" => "SME",
        "local_entity" => "Local entity"
      }

      user_types.each do |type_value, type_label|
        user.update(extended_data: { "user_type" => type_value })

        visit decidim.profile_path(user.nickname)

        expect(page).to have_content(type_label)
      end
    end
  end

  context "when user does not have a user_type" do
    let!(:user) do
      create(
        :user,
        :confirmed,
        organization: organization,
        name: "Jane Doe",
        nickname: "janedoe",
        extended_data: {}
      )
    end

    before do
      switch_to_host(organization.host)
    end

    it "does not display user type section" do
      visit decidim.profile_path(user.nickname)

      expect(page).to have_content("Jane Doe")
      expect(page).to have_no_css(".profile__details-user-type")
    end
  end

  context "when viewing a user group profile" do
    let!(:user_group) do
      create(
        :user_group,
        :verified,
        organization: organization,
        name: "Energy Community",
        nickname: "energycommunity"
      )
    end

    before do
      switch_to_host(organization.host)
    end

    it "does not display user type for groups" do
      visit decidim.profile_path(user_group.nickname)

      expect(page).to have_content("Energy Community")
      expect(page).to have_no_css(".profile__details-user-type")
    end
  end
end
