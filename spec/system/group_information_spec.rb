# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Group information tab" do
  let(:organization) { create(:organization) }
  let(:admin_user) { create(:user, :admin, :confirmed, organization: organization) }
  let(:group) do
    create(:user_group, organization: organization, nickname: "my-group", about: "<p>About the group</p>")
  end

  before do
    switch_to_host(organization.host)
    login_as admin_user, scope: :user
    visit decidim.profile_information_path(nickname: group.nickname)
  end

  it "shows the about information when present" do
    expect(page).to have_content("About the group")
    expect(page).to have_css(".profile__group-information")
  end

  context "when about is blank" do
    let(:group) do
      create(:user_group, organization: organization, nickname: "empty-about-group", about: nil)
    end

    it "shows the no information message" do
      visit decidim.profile_information_path(nickname: group.nickname)
      expect(page).to have_content(I18n.t("decidim.profiles.show.no_information"))
    end
  end
end
