# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Homepage Energy Communities Map Content Block" do
  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, :confirmed, organization: organization) }

  before do
    switch_to_host(organization.host)
    # Disable geocoding callback for tests
    allow_any_instance_of(Decidim::UserGroup).to receive(:geocode) # rubocop:disable RSpec/AnyInstance
  end

  context "when visiting the homepage without the content block" do
    it "does not display the energy communities map" do
      visit decidim.root_path

      expect(page).to have_no_css("#homepage-user-groups-map")
    end
  end

  context "when managing content blocks as admin" do
    before do
      login_as admin, scope: :user
    end

    it "shows the energy communities map content block as available", :js do
      visit decidim_admin.edit_organization_homepage_path

      click_on "Add content block"

      within ".dropdown-pane" do
        expect(page).to have_content("Energy Communities map")
      end
    end

    it "can create the energy communities map content block", :js do
      visit decidim_admin.edit_organization_homepage_path

      # Add the content block
      click_on "Add content block"

      within ".dropdown-pane" do
        click_on "Energy Communities map"
      end

      # Wait for success message
      expect(page).to have_content("Content block successfully created")

      # The new content block should appear in the inactive list by default
      within ".js-list-available" do
        expect(page).to have_content("Energy Communities map")
      end
    end
  end

  context "when the content block is active on the homepage" do
    let!(:content_block) do
      # Create the content block and make it active
      Decidim::ContentBlock.create!(
        organization: organization,
        scope_name: :homepage,
        manifest_name: :user_groups_map,
        weight: 1,
        published_at: Time.current
      )
    end

    before do
      switch_to_host(organization.host)
    end

    it "displays the energy communities section" do
      visit decidim.root_path

      expect(page).to have_css("#homepage-user-groups-map")
      expect(page).to have_content(I18n.t("decidim.content_blocks.user_groups_map.title", locale: :en))
    end

    context "when there are geocoded user groups" do
      let!(:user_group_one) do
        create(:user_group, organization: organization, name: "Barcelona Energy Community").tap do |ug|
          ug.update!(
            address: "Carrer de la Pau, 08001 Barcelona, España",
            latitude: 41.3851,
            longitude: 2.1734
          )
        end
      end

      let!(:user_group_two) do
        create(:user_group, organization: organization, name: "Madrid Energy Community").tap do |ug|
          ug.update!(
            address: "Gran Via, 28013 Madrid, España",
            latitude: 40.4168,
            longitude: -3.7038
          )
        end
      end

      it "displays the map with the geocoded communities" do
        visit decidim.root_path

        expect(page).to have_css("#homepage-user-groups-map")
        expect(page).to have_content(I18n.t("decidim.content_blocks.user_groups_map.title", locale: :en))
        expect(page).to have_css(".user-groups-list__map")

        # The map container should have the dynamic map data
        expect(page).to have_css("[data-decidim-map]")
      end
    end
  end
end
