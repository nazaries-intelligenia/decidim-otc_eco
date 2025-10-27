# frozen_string_literal: true

require "rails_helper"

RSpec.describe "User groups map display" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user

    # Disable geocoding callback for tests
    allow_any_instance_of(Decidim::UserGroup).to receive(:geocode) # rubocop:disable RSpec/AnyInstance
  end

  context "when there are no user groups" do
    it "does not display the map section" do
      visit decidim.profile_groups_path(nickname: user.nickname)

      expect(page).to have_no_css(".user-groups-list__map")
    end
  end

  context "when there are user groups without geocoding" do
    let!(:user_group_without_geocoding) do
      create(:user_group, organization: organization, name: "Community Without Location")
    end

    before do
      # Add the user as a member of the group to see it in their profile
      create(:user_group_membership, user: user, user_group: user_group_without_geocoding, role: "admin")
    end

    it "does not display the map section" do
      visit decidim.profile_groups_path(nickname: user.nickname)

      expect(page).to have_no_css(".user-groups-list__map")
    end
  end

  context "when there is one user group with geocoding" do
    let!(:user_group_with_geocoding) do
      create(:user_group, organization: organization, name: "Barcelona Energy Community").tap do |ug|
        ug.update!(
          address: "Carrer de la Pau, 08001 Barcelona, España",
          latitude: 41.3851,
          longitude: 2.1734
        )
      end
    end

    before do
      create(:user_group_membership, user: user, user_group: user_group_with_geocoding, role: "admin")
    end

    it "displays the map section with the geocoded user group" do
      visit decidim.profile_groups_path(nickname: user.nickname)

      expect(page).to have_css(".user-groups-list__map")
      expect(page).to have_content("Barcelona Energy Community")
    end

    it "displays the map before the user groups grid" do
      visit decidim.profile_groups_path(nickname: user.nickname)

      map_position = page.body.index("user-groups-list__map")
      grid_position = page.body.index("profile__user-grid")

      expect(map_position).to be < grid_position
    end
  end

  context "when there are multiple user groups with and without geocoding" do
    let!(:user_group_with_geocoding_one) do
      create(:user_group, organization: organization, name: "Barcelona Community").tap do |ug|
        ug.update!(
          address: "Carrer de la Pau, 08001 Barcelona, España",
          latitude: 41.3851,
          longitude: 2.1734
        )
      end
    end

    let!(:user_group_with_geocoding_two) do
      create(:user_group, organization: organization, name: "Madrid Community").tap do |ug|
        ug.update!(
          address: "Gran Via, 28013 Madrid, España",
          latitude: 40.4168,
          longitude: -3.7038
        )
      end
    end

    let!(:user_group_without_geocoding) do
      create(:user_group, organization: organization, name: "Virtual Community")
    end

    before do
      create(:user_group_membership, user: user, user_group: user_group_with_geocoding_one, role: "admin")
      create(:user_group_membership, user: user, user_group: user_group_with_geocoding_two, role: "admin")
      create(:user_group_membership, user: user, user_group: user_group_without_geocoding, role: "admin")
    end

    it "displays the map section when at least one user group has geocoding" do
      visit decidim.profile_groups_path(nickname: user.nickname)

      expect(page).to have_css(".user-groups-list__map")
    end

    it "displays all user groups in the grid (geocoded and non-geocoded)" do
      visit decidim.profile_groups_path(nickname: user.nickname)

      expect(page).to have_content("Barcelona Community")
      expect(page).to have_content("Madrid Community")
      expect(page).to have_content("Virtual Community")
    end
  end

  context "when viewing another user's groups page" do
    let(:other_user) { create(:user, :confirmed, organization: organization) }
    let!(:other_user_group) do
      create(:user_group, organization: organization, name: "Other User Community").tap do |ug|
        ug.update!(
          address: "Valencia, España",
          latitude: 39.4699,
          longitude: -0.3763
        )
      end
    end

    before do
      create(:user_group_membership, user: other_user, user_group: other_user_group, role: "admin")
    end

    it "displays the map with the other user's geocoded groups" do
      visit decidim.profile_groups_path(nickname: other_user.nickname)

      expect(page).to have_css(".user-groups-list__map")
      expect(page).to have_content("Other User Community")
    end
  end
end
