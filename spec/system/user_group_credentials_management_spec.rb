# frozen_string_literal: true

require "rails_helper"

# Test for user group credentials management (CIF and Datadis password)
RSpec.describe "User group credentials management" do
  let(:organization) { create(:organization) }
  let(:user_group) { create(:user_group, organization: organization) }
  let(:admin_user) { create(:user, :confirmed, organization: organization) }
  let(:regular_member) { create(:user, :confirmed, organization: organization) }

  let!(:admin_membership) do
    create(:user_group_membership,
           user: admin_user,
           user_group: user_group,
           role: "admin")
  end

  let!(:regular_membership) do
    create(:user_group_membership,
           user: regular_member,
           user_group: user_group,
           role: "member")
  end

  before do
    switch_to_host(organization.host)
  end

  context "when user is a regular member of the group" do
    before do
      login_as regular_member, scope: :user
      visit decidim.profile_members_path(nickname: user_group.nickname)
    end

    it "does not show the 'Manage credentials' button" do
      # Open the dropdown menu if it exists
      if page.has_css?(".profile__actions-main__dropdown-trigger")
        find(".profile__actions-main__dropdown-trigger").click
        sleep 0.5 # Wait for dropdown to open
      end

      expect(page).to have_no_link("Manage credentials (CIF and password)")
    end

    it "does not show the missing credentials alert" do
      expect(page).to have_no_content("You need to configure the CIF and password")
    end
  end

  context "when user is an admin of the group" do
    before do
      login_as admin_user, scope: :user
    end

    context "and credentials are not yet configured" do
      before do
        user_group.update!(cif: nil, datadis_password: nil)
        visit decidim.profile_members_path(nickname: user_group.nickname)
      end

      it "shows the 'Manage credentials' button in the actions menu" do
        # Open the dropdown menu
        find(".profile__actions-main__dropdown-trigger").click
        sleep 0.5 # Wait for dropdown to open

        expect(page).to have_link("Manage credentials (CIF and password)")
      end

      it "shows an alert about missing credentials" do
        expect(page).to have_content("You need to configure the CIF and password")
      end

      it "allows the admin to configure CIF and password through the form" do
        # Open the dropdown menu and click on Manage credentials
        find(".profile__actions-main__dropdown-trigger").click
        sleep 0.5 # Wait for dropdown to open
        click_on "Manage credentials (CIF and password)"

        # Verify we're on the credentials form page
        expect(page).to have_content("Manage energy community credentials")
        expect(page).to have_field("user_group_cif")
        expect(page).to have_field("user_group_datadis_password")

        # Fill in the form with valid credentials
        fill_in "user_group_cif", with: "A12345678"
        fill_in "user_group_datadis_password", with: "test_password_123"

        # Submit the form
        click_on "Save credentials"

        # Verify success message and redirect
        expect(page).to have_content("Credentials have been successfully updated")
        expect(page).to have_current_path(decidim.profile_members_path(nickname: user_group.nickname))

        # Verify the credentials were saved in the database
        user_group.reload
        expect(user_group.cif).to eq("A12345678")
        # The password should be encrypted in the database
        # We read the encrypted value directly from the database attributes
        expect(user_group.read_attribute(:datadis_password)).not_to be_nil
        expect(user_group.read_attribute(:datadis_password)).not_to eq("test_password_123") # Should be encrypted
      end
    end

    context "and credentials are already configured" do
      before do
        user_group.update!(cif: "B87654321", datadis_password: "existing_password")
        visit decidim.profile_members_path(nickname: user_group.nickname)
      end

      it "does not show the missing credentials alert" do
        expect(page).to have_no_content("You need to configure the CIF and password")
      end
    end

    context "when visiting other group pages (group_admins)" do
      before do
        user_group.update!(cif: nil, datadis_password: nil)
      end

      it "shows the alert on group_admins page" do
        visit decidim.profile_group_admins_path(nickname: user_group.nickname)
        expect(page).to have_content("You need to configure the CIF and password")
      end
    end
  end

  context "when validating CIF format" do
    before do
      login_as admin_user, scope: :user
      visit decidim.edit_user_group_credentials_path(nickname: user_group.nickname)
    end

    it "shows an error for invalid CIF format" do
      fill_in "user_group_cif", with: "invalid"
      fill_in "user_group_datadis_password", with: "test_password"

      click_on "Save credentials"

      expect(page).to have_content("There was an error updating the credentials")
    end

    it "accepts valid CIF format (capital letter + 8 digits)" do
      fill_in "user_group_cif", with: "Z99999999"
      fill_in "user_group_datadis_password", with: "test_password"

      click_on "Save credentials"

      expect(page).to have_content("Credentials have been successfully updated")
    end
  end
end
