# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User account edit user type" do
  let(:organization) { create(:organization) }
  let!(:user) do
    create(
      :user,
      :confirmed,
      organization: organization,
      password: "decidim123456789",
      extended_data: { "user_type" => "individual" }
    )
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
  end

  it "allows a user to edit their user type" do
    visit decidim.account_path

    expect(page).to have_select("User type", selected: "Individual")

    select "SME", from: "User type"
    click_on "Update account"

    expect(page).to have_content("Your account was successfully updated")

    user.reload
    expect(user.extended_data["user_type"]).to eq("pyme")
  end

  it "can change user type multiple times" do
    visit decidim.account_path

    # Change from Individual to Local entity
    select "Local entity", from: "User type"
    click_on "Update account"

    expect(page).to have_content("Your account was successfully updated")
    user.reload
    expect(user.extended_data["user_type"]).to eq("local_entity")

    # Change from Local entity to SME
    select "SME", from: "User type"
    click_on "Update account"

    expect(page).to have_content("Your account was successfully updated")
    user.reload
    expect(user.extended_data["user_type"]).to eq("pyme")
  end

  it "preserves other extended_data fields when updating user type" do
    user.update(extended_data: { "user_type" => "individual", "custom_field" => "custom_value" })

    visit decidim.account_path

    select "Local entity", from: "User type"
    click_on "Update account"

    user.reload
    expect(user.extended_data["user_type"]).to eq("local_entity")
    expect(user.extended_data["custom_field"]).to eq("custom_value")
  end

  it "shows the current user type when loading the form" do
    user.update(extended_data: { "user_type" => "pyme" })

    visit decidim.account_path

    expect(page).to have_select("User type", selected: "SME")
  end
end
