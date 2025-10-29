# frozen_string_literal: true

require "rails_helper"

# We make sure that the checksum of the file overridden is the same
# as the expected. If this test fails, it means that the overridden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-core",
    files: {
      "/app/permissions/decidim/permissions.rb" => "89cdeb04aca3775b876bf497ac3cc2fb",
      "/app/cells/decidim/profile_actions_cell.rb" => "58dc7248028205c01a370243fb7b6b6f",
      "/app/cells/decidim/groups_cell.rb" => "cd5c80bf992322ced5c93da7415bdb03",
      "/app/cells/decidim/groups/show.erb" => "9187e30d2e6ab17903f0a9929bffded4",
      "/config/locales/en.yml" => "f70e1c80e82314a99f14011b865db190",
      "/config/locales/es.yml" => "139f08e385b564b8d92610b0fa053e95",
      "/app/models/decidim/user_group.rb" => "bfd3dad56e66adf9d8dbf1a9d9c4fcd4",
      "/app/commands/decidim/create_user_group.rb" => "3dbf8247f6b949d3b700dc5cdfb54d9c",
      "/app/commands/decidim/update_user_group.rb" => "d714c339efc3ea9ff064246f6bc8ef83",
      "/app/commands/decidim/accept_group_invitation.rb" => "843946937cb0f7104f7e672c70f45dd8",
      "/app/commands/decidim/accept_user_group_join_request.rb" => "b2753c5bfae52c904c2f73cc3c8a84ec",
      "/app/commands/decidim/leave_user_group.rb" => "c48bb5f45bdbf4966171dc4f0f6921db",
      "/app/commands/decidim/remove_user_from_group.rb" => "ed09c455dce565355bf4d64456e03f2b",
      "/app/views/decidim/groups/_form.html.erb" => "c0fe379ba854c18a5c6c2f32f146bf38",
      "/app/forms/decidim/user_group_form.rb" => "841f9cc427698a42764873504589151e"
    }
  },
  {
    package: "decidim-assemblies",
    files: {
      "/app/models/decidim/assembly.rb" => "f44461dcbc95371a00feb69077b61355"
    }
  }
]

describe "Overridden files", type: :view do
  checksums.each do |item|
    spec = Gem::Specification.find_by_name(item[:package])

    item[:files].each do |file, signature|
      next unless spec

      it "#{spec.gem_dir}#{file} matches checksum" do
        expect(md5("#{spec.gem_dir}#{file}")).to eq(signature)
      end
    end
  end

  private

  def md5(file)
    Digest::MD5.hexdigest(File.read(file))
  end
end
