# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User registration with user type" do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  it "allows a user to register with a user type and stores it correctly" do
    visit decidim.new_user_registration_path

    fill_in "registration_user_name", with: "John Doe"
    fill_in "registration_user_email", with: "john@example.org"
    select "SME", from: "registration_user_user_type"
    fill_in "registration_user_password", with: "decidim123456789"
    check "registration_user_tos_agreement"
    check "registration_user_newsletter"

    within "form.new_user" do
      click_on "Create an account"
    end

    # Close newsletter modal if present
    if page.has_css?("#newsletterModal", visible: :all)
      within "#newsletterModal", visible: false do
        click_on "Check and continue"
      end
    end

    expect(page).to have_content("A message with a confirmation link")

    user = Decidim::User.find_by(email: "john@example.org")
    expect(user).to be_present
    expect(user.extended_data["user_type"]).to eq("pyme")
  end

  it "requires user type to be selected" do
    visit decidim.new_user_registration_path

    fill_in "registration_user_name", with: "Jane Doe"
    fill_in "registration_user_email", with: "jane@example.org"
    fill_in "registration_user_password", with: "decidim123456789"
    check "registration_user_tos_agreement"

    within "form.new_user" do
      click_on "Create an account"
    end

    expect(page).to have_content("There are errors on the form")
    expect(page).to have_content("There is an error in this field")
  end

  it "stores different user types correctly" do
    user_types = {
      "Individual" => "individual",
      "SME" => "pyme",
      "Local entity" => "local_entity"
    }

    user_types.each do |label, value|
      visit decidim.new_user_registration_path

      email = "user_#{value}@example.org"
      fill_in "registration_user_name", with: "User #{label}"
      fill_in "registration_user_email", with: email
      select label, from: "registration_user_user_type"
      fill_in "registration_user_password", with: "decidim123456789"
      check "registration_user_tos_agreement"
      check "registration_user_newsletter"

      within "form.new_user" do
        click_on "Create an account"
      end

      # Close newsletter modal if present
      if page.has_css?("#newsletterModal", visible: :all)
        within "#newsletterModal", visible: false do
          click_on "Check and continue"
        end
      end

      expect(page).to have_content("A message with a confirmation link")

      user = Decidim::User.find_by(email: email)
      expect(user).to be_present
      expect(user.extended_data["user_type"]).to eq(value)
    end
  end
end
