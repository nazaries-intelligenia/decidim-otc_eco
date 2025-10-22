# frozen_string_literal: true

require "rails_helper"

RSpec.describe Decidim::UserGroup do
  let(:organization) { create(:organization) }
  let(:user_group) { create(:user_group, organization: organization) }

  it "can have one assembly associated (has_one :assembly)" do
    assembly = Decidim::Assembly.create!(
      title: { "en" => "UG Assembly" },
      subtitle: { "en" => "Subtitle" },
      short_description: { "en" => "Short" },
      description: { "en" => "Description" },
      slug: "ug-assembly",
      private_space: true,
      is_transparent: false,
      user_group: user_group,
      decidim_organization_id: organization.id
    )

    expect(user_group.assembly).to eq(assembly)
    expect(assembly.decidim_user_group_id).to eq(user_group.id)
  end

  it "does not require an assembly (association is optional)" do
    expect(user_group.assembly).to be_nil
    expect(user_group).to be_valid
  end

  it "destroys the associated assembly when the user_group is destroyed" do
    Decidim::Assembly.create!(
      title: { "en" => "UG Assembly" },
      subtitle: { "en" => "Subtitle" },
      short_description: { "en" => "Short" },
      description: { "en" => "Description" },
      slug: "ug-assembly",
      private_space: true,
      is_transparent: false,
      user_group: user_group,
      decidim_organization_id: organization.id
    )

    expect(Decidim::Assembly.exists?(user_group: user_group)).to be true

    expect { user_group.destroy }.to change(Decidim::Assembly, :count).by(-1)
  end
end
