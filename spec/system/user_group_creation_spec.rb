# frozen_string_literal: true

require "rails_helper"

# Simple test that verifies user group creation is restricted to admins only
RSpec.describe "User group creation" do
  let(:organization) { create(:organization) }
  let(:regular_user) { create(:user, :confirmed, organization: organization) }
  let(:admin_user) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim.profile_groups_path(nickname: user.nickname)
  end

  context "when user is a regular user" do
    let(:user) { regular_user }

    it "does not show create_user_group button in the rendered view" do
      expect(page).to have_no_link("Create energy community")
      expect(page).to have_no_css("a[href*='groups/new']")
    end
  end

  context "when user is an admin" do
    let(:user) { admin_user }

    it "shows create_user_group button in the rendered view" do
      expect(page).to have_link("Create energy community")
      expect(page).to have_css("a[href*='groups/new']")
    end
  end
end
