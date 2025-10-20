# frozen_string_literal: true

require "rails_helper"

RSpec.describe Decidim::Assembly do
  let(:organization) { create(:organization) }
  let(:user_group) { create(:user_group, organization: organization) }

  it "can belong to a user_group (optional association)" do
    assembly = Decidim::Assembly.create!(
      title: { "en" => "Assembly" },
      subtitle: { "en" => "Subtitle" },
      short_description: { "en" => "Short" },
      description: { "en" => "Description" },
      slug: "ug-assembly",
      private_space: true,
      is_transparent: false,
      user_group: user_group,
      decidim_organization_id: organization.id
    )

    expect(assembly.user_group).to eq(user_group)
    expect(assembly.decidim_user_group_id).to eq(user_group.id)
  end

  it "is valid without a user_group (association is optional)" do
    assembly = Decidim::Assembly.create!(
      title: { "en" => "Assembly 2" },
      subtitle: { "en" => "Subtitle 2" },
      short_description: { "en" => "Short 2" },
      description: { "en" => "Description 2" },
      slug: "no-group-assembly",
      private_space: false,
      is_transparent: true,
      decidim_organization_id: organization.id
    )

    expect(assembly.user_group).to be_nil
    expect(assembly).to be_valid
  end
end
