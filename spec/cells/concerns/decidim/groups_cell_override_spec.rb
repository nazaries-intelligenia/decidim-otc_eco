# frozen_string_literal: true

require "rails_helper"

module Decidim
  RSpec.describe GroupsCellOverride, type: :cell do
    let(:organization) { create(:organization) }
    let!(:user) { create(:user, :confirmed, organization: organization) }

    describe "included in GroupsCell" do
      subject { cell("decidim/groups", user) }

      describe "#geocoded_user_groups" do
        context "when there are no user groups" do
          it "returns an empty array" do
            expect(subject.geocoded_user_groups).to be_empty
          end
        end

        context "when there are user groups without geocoding" do
          let!(:user_group_without_geocoding) do
            create(:user_group, organization: organization)
          end

          it "does not include user groups without geocoding" do
            expect(subject.geocoded_user_groups).not_to include(user_group_without_geocoding)
          end
        end

        context "when there are user groups with complete geocoding data" do
          let!(:user_group_with_geocoding) do
            create(:user_group, organization: organization).tap do |ug|
              ug.update!(
                address: "Carrer de la Pau, 08001 Barcelona, España",
                latitude: 41.3851,
                longitude: 2.1734
              )
            end
          end

          it "returns the geocoded user groups" do
            expect(subject.geocoded_user_groups).to include(user_group_with_geocoding)
            expect(subject.geocoded_user_groups.size).to eq(1)
          end
        end

        context "when there are mixed user groups (with and without geocoding)" do
          let!(:user_group_with_geocoding) do
            create(:user_group, organization: organization).tap do |ug|
              ug.update!(
                address: "Carrer de la Pau, 08001 Barcelona, España",
                latitude: 41.3851,
                longitude: 2.1734
              )
            end
          end
          let!(:user_group_without_geocoding) do
            create(:user_group, organization: organization)
          end

          it "returns only geocoded user groups" do
            geocoded_groups = subject.geocoded_user_groups
            expect(geocoded_groups).to include(user_group_with_geocoding)
            expect(geocoded_groups).not_to include(user_group_without_geocoding)
            expect(geocoded_groups.size).to eq(1)
          end
        end

        context "when there are multiple geocoded user groups" do
          let!(:user_group1) do
            create(:user_group, organization: organization).tap do |ug|
              ug.update!(
                address: "Carrer de la Pau, 08001 Barcelona, España",
                latitude: 41.3851,
                longitude: 2.1734
              )
            end
          end
          let!(:user_group2) do
            create(:user_group, organization: organization).tap do |ug|
              ug.update!(
                address: "Gran Via, 28013 Madrid, España",
                latitude: 40.4168,
                longitude: -3.7038
              )
            end
          end

          it "returns all geocoded user groups" do
            expect(subject.geocoded_user_groups).to include(user_group1, user_group2)
            expect(subject.geocoded_user_groups.size).to eq(2)
          end
        end

        it "memoizes the result" do
          first_call = subject.geocoded_user_groups
          second_call = subject.geocoded_user_groups

          expect(first_call.object_id).to eq(second_call.object_id)
        end
      end

      describe "#display_map?" do
        context "when map is not available" do
          before do
            allow(Decidim::Map).to receive(:available?).with(:geocoding, :dynamic).and_return(false)
          end

          it "returns false" do
            expect(subject.display_map?).to be false
          end
        end

        context "when map is available but there are no geocoded user groups" do
          before do
            allow(Decidim::Map).to receive(:available?).with(:geocoding, :dynamic).and_return(true)
          end

          it "returns false" do
            expect(subject.display_map?).to be false
          end
        end

        context "when map is available and there are geocoded user groups" do
          let!(:user_group_with_geocoding) do
            create(:user_group, organization: organization).tap do |ug|
              ug.update!(
                address: "Carrer de la Pau, 08001 Barcelona, España",
                latitude: 41.3851,
                longitude: 2.1734
              )
            end
          end

          before do
            allow(Decidim::Map).to receive(:available?).with(:geocoding, :dynamic).and_return(true)
          end

          it "returns true" do
            expect(subject.display_map?).to be true
          end
        end

        context "when map is not available even with geocoded user groups" do
          let!(:user_group_with_geocoding) do
            create(:user_group, organization: organization).tap do |ug|
              ug.update!(
                address: "Carrer de la Pau, 08001 Barcelona, España",
                latitude: 41.3851,
                longitude: 2.1734
              )
            end
          end

          before do
            allow(Decidim::Map).to receive(:available?).with(:geocoding, :dynamic).and_return(false)
          end

          it "returns false" do
            expect(subject.display_map?).to be false
          end
        end
      end
    end
  end
end
