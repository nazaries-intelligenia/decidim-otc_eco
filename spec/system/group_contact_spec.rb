# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Group contact tab" do
  let(:organization) { create(:organization) }
  let(:admin_user) { create(:user, :admin, :confirmed, organization: organization) }

  let(:group_with_full_contact) do
    create(
      :user_group,
      organization: organization,
      nickname: "contact-group",
      email: "group@example.org",
      phone: "+34123456789",
      extended_data: { "contact_person" => "Jane Doe" }
    )
  end

  let(:group_without_phone) do
    create(
      :user_group,
      organization: organization,
      nickname: "no-phone-group",
      email: "group2@example.org",
      extended_data: { "contact_person" => "John Smith" }
    ).tap do |group|
      # Remove phone from extended_data if the factory added it
      group.extended_data.delete("phone")
      group.save!
    end
  end

  before do
    switch_to_host(organization.host)
    login_as admin_user, scope: :user
  end

  it "shows contact person, email and phone when all present" do
    visit decidim.profile_contact_path(nickname: group_with_full_contact.nickname)

    expect(page).to have_css(".profile__group-contact")
    expect(page).to have_content("Jane Doe")
    expect(page).to have_link("group@example.org", href: /mailto:|group@example.org/)
    expect(page).to have_link(
      "+34123456789",
      href: /tel:\+34123456789/
    )
  end

  context "when phone is not present" do
    it "shows contact person and email without phone" do
      visit decidim.profile_contact_path(nickname: group_without_phone.nickname)

      expect(page).to have_css(".profile__group-contact")
      expect(page).to have_content("John Smith")
      expect(page).to have_link("group2@example.org", href: /mailto:|group2@example.org/)
      expect(page).to have_no_content(I18n.t("decidim.profiles.show.phone"))
    end
  end
end
