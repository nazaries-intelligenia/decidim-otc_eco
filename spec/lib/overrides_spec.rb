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
      "/app/models/decidim/user_group.rb" => "bfd3dad56e66adf9d8dbf1a9d9c4fcd4",
      "/app/forms/decidim/user_group_form.rb" => "841f9cc427698a42764873504589151e",
      "/app/views/decidim/groups/_form.html.erb" => "c0fe379ba854c18a5c6c2f32f146bf38",
      "/app/commands/decidim/create_user_group.rb" => "3dbf8247f6b949d3b700dc5cdfb54d9c"
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
