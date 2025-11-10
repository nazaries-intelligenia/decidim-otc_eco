# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Footer Logos" do
  let(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  context "when visiting the homepage" do
    it "displays custom footer with logos" do
      visit decidim.root_path

      # Verify the custom footer is present
      expect(page).to have_css(".mini-footer")
      expect(page).to have_css(".mini-footer__content")
      expect(page).to have_css(".mini-footer__logo--dipgra")
      expect(page).to have_css(".mini-footer__logo--energia")
      expect(page).to have_css(".mini-footer__logo-gobierno")
    end
  end
end
