# frozen_string_literal: true

Rails.application.config.to_prepare do
  # Register custom content blocks
  Decidim.content_blocks.register(:homepage, :user_groups_map) do |content_block|
    content_block.cell = "decidim/content_blocks/user_groups_map"
    content_block.public_name_key = "decidim.content_blocks.user_groups_map.name"
  end
end
