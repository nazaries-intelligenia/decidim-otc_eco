# frozen_string_literal: true

require "rails_helper"

module Decidim
  module UserGroups
    RSpec.describe UserGroupCardMetadataCell, type: :cell do
      let(:organization) { create(:organization) }
      let(:user_group) { create(:user_group, organization: organization, nickname: "test_community") }

      subject { cell("decidim/user_groups/user_group_card_metadata", user_group) }

      describe "#initialize" do
        it "prepends user_group_items to @items" do
          expect(subject.instance_variable_get(:@items)).not_to be_empty
        end
      end

      describe "#nickname_item" do
        context "when user_group has a nickname" do
          it "returns a hash with nickname text and icon" do
            nickname_item = subject.send(:nickname_item)

            expect(nickname_item).to be_a(Hash)
            expect(nickname_item[:text]).to eq("@test_community")
            expect(nickname_item[:icon]).to eq("account-circle-line")
          end
        end

        context "when nickname is accessed and happens to be blank" do
          before do
            allow(user_group).to receive(:nickname).and_return(nil)
          end

          it "returns nil" do
            nickname_item = subject.send(:nickname_item)

            expect(nickname_item).to be_nil
          end
        end
      end

      describe "#members_count_item" do
        context "when user_group has no memberships" do
          it "returns nil" do
            members_item = subject.send(:members_count_item)

            expect(members_item).to be_nil
          end
        end

        context "when user_group has only requested members" do
          let!(:user) { create(:user, organization: organization) }
          let!(:membership) do
            create(:user_group_membership,
                   user: user,
                   user_group: user_group,
                   role: "requested")
          end

          it "returns nil because requested members are not counted" do
            members_item = subject.send(:members_count_item)

            expect(members_item).to be_nil
          end
        end

        context "when user_group has one member" do
          let!(:user) { create(:user, organization: organization) }
          let!(:membership) do
            create(:user_group_membership,
                   user: user,
                   user_group: user_group,
                   role: "member")
          end

          it "returns a hash with members count text and icon" do
            members_item = subject.send(:members_count_item)

            expect(members_item).to be_a(Hash)
            expect(members_item[:text]).to include("1")
            expect(members_item[:icon]).to eq("group-line")
          end
        end

        context "when user_group has multiple members" do
          let!(:user1) { create(:user, organization: organization) }
          let!(:user2) { create(:user, organization: organization) }
          let!(:membership1) do
            create(:user_group_membership,
                   user: user1,
                   user_group: user_group,
                   role: "admin")
          end
          let!(:membership2) do
            create(:user_group_membership,
                   user: user2,
                   user_group: user_group,
                   role: "member")
          end

          it "returns a hash with correct members count" do
            members_item = subject.send(:members_count_item)

            expect(members_item).to be_a(Hash)
            expect(members_item[:text]).to include("2")
            expect(members_item[:icon]).to eq("group-line")
          end
        end

        context "when user_group has mixed members (accepted and requested)" do
          let!(:user1) { create(:user, organization: organization) }
          let!(:user2) { create(:user, organization: organization) }
          let!(:user3) { create(:user, organization: organization) }
          let!(:membership1) do
            create(:user_group_membership,
                   user: user1,
                   user_group: user_group,
                   role: "admin")
          end
          let!(:membership2) do
            create(:user_group_membership,
                   user: user2,
                   user_group: user_group,
                   role: "member")
          end
          let!(:membership3) do
            create(:user_group_membership,
                   user: user3,
                   user_group: user_group,
                   role: "requested")
          end

          it "counts only non-requested members" do
            members_item = subject.send(:members_count_item)

            expect(members_item).to be_a(Hash)
            expect(members_item[:text]).to include("2")
            expect(members_item[:text]).not_to include("3")
          end
        end
      end

      describe "#user_group_items" do
        context "when user_group has members" do
          let!(:user) { create(:user, organization: organization) }
          let!(:membership) do
            create(:user_group_membership,
                   user: user,
                   user_group: user_group,
                   role: "member")
          end

          it "returns an array with nickname_item and members_count_item" do
            items = subject.send(:user_group_items)

            expect(items).to be_an(Array)
            expect(items.size).to eq(2)
            expect(items.first[:text]).to eq("@test_community")
            expect(items.last[:text]).to include("1")
          end
        end

        context "when user_group has no accepted members" do
          it "includes nickname_item and nil for members" do
            items = subject.send(:user_group_items)

            expect(items).to be_an(Array)
            expect(items.size).to eq(2)
            expect(items.first[:text]).to eq("@test_community")
            expect(items.last).to be_nil
          end
        end
      end

      describe "#items_for_map" do
        let!(:user) { create(:user, organization: organization) }
        let!(:membership) do
          create(:user_group_membership,
                 user: user,
                 user_group: user_group,
                 role: "admin")
        end

        it "returns an array of hashes with text and icon for the map" do
          items = subject.send(:items_for_map)

          expect(items).to be_an(Array)
          expect(items.size).to eq(2)
          expect(items.first).to have_key(:text)
          expect(items.first).to have_key(:icon)
        end

        it "includes the nickname item" do
          items = subject.send(:items_for_map)
          nickname_item = items.find { |item| item[:text].include?("@test_community") }

          expect(nickname_item).not_to be_nil
          expect(nickname_item[:text]).to eq("@test_community")
        end

        it "includes the members count item" do
          items = subject.send(:items_for_map)
          members_item = items.find { |item| item[:text].include?("1") }

          expect(members_item).not_to be_nil
        end

        it "returns icons as html_safe strings" do
          items = subject.send(:items_for_map)

          items.each do |item|
            expect(item[:icon]).to be_html_safe
          end
        end

        context "when user_group has no members" do
          it "filters out blank items with compact_blank" do
            # Create a new user_group without members for this test
            new_user_group = create(:user_group, organization: organization, nickname: "no_members_group")
            new_subject = cell("decidim/user_groups/user_group_card_metadata", new_user_group)

            items = new_subject.send(:items_for_map)

            # Should only include nickname_item because there are no members
            expect(items.size).to eq(1)
            expect(items.first[:text]).to eq("@no_members_group")
            expect(items.first[:icon]).to be_html_safe
          end
        end

        context "with multiple members" do
          let!(:user2) { create(:user, organization: organization) }
          let!(:user3) { create(:user, organization: organization) }
          let!(:membership2) do
            create(:user_group_membership,
                   user: user2,
                   user_group: user_group,
                   role: "member")
          end
          let!(:membership3) do
            create(:user_group_membership,
                   user: user3,
                   user_group: user_group,
                   role: "member")
          end

          it "shows the correct count in items_for_map" do
            items = subject.send(:items_for_map)
            members_item = items.find { |item| item[:text].include?("3") }

            expect(members_item).not_to be_nil
            expect(members_item[:text]).to include("3")
          end
        end
      end

      describe "delegation" do
        it "delegates nickname to user_group" do
          expect(subject.nickname).to eq("test_community")
        end
      end

      describe "alias" do
        it "aliases model as user_group" do
          expect(subject.user_group).to eq(user_group)
        end
      end
    end
  end
end
