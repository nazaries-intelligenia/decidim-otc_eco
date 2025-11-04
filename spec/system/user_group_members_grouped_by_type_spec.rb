# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User group members grouped by type" do
  let(:organization) { create(:organization) }
  let!(:user_group) { create(:user_group, :verified, organization: organization) }

  before do
    # Create members with different user types
    create(:user_group_membership, user: create(:user, :confirmed, organization: organization, extended_data: { "user_type" => "individual" }), user_group: user_group, role: "creator")
    create(:user_group_membership, user: create(:user, :confirmed, organization: organization, name: "Juan Rodríguez", extended_data: { "user_type" => "individual" }), user_group: user_group, role: "member")
    create(:user_group_membership, user: create(:user, :confirmed, organization: organization, name: "José Pérez", extended_data: { "user_type" => "individual" }), user_group: user_group, role: "member")
    create(:user_group_membership, user: create(:user, :confirmed, organization: organization, name: "Hermanos González S.L.", extended_data: { "user_type" => "pyme" }), user_group: user_group, role: "member")
    create(:user_group_membership, user: create(:user, :confirmed, organization: organization, name: "Ayuntamiento de Órgiva", extended_data: { "user_type" => "local_entity" }), user_group: user_group, role: "member")
    create(:user_group_membership, user: create(:user, :confirmed, organization: organization, name: "Ayuntamiento de Lanjarón", extended_data: { "user_type" => "local_entity" }), user_group: user_group, role: "member")

    switch_to_host(organization.host)
    visit decidim.profile_members_path(user_group.nickname)
  end

  it "displays members grouped by user type with counts" do
    expect(page).to have_content("Individual (3)")
    expect(page).to have_content("SME (1)")
    expect(page).to have_content("Local entity (2)")

    expect(page).to have_content("Juan Rodríguez")
    expect(page).to have_content("José Pérez")
    expect(page).to have_content("Hermanos González S.L.")
    expect(page).to have_content("Ayuntamiento de Órgiva")
    expect(page).to have_content("Ayuntamiento de Lanjarón")
  end
end
