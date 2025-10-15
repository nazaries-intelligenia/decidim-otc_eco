# frozen_string_literal: true

class AddUserGroupToDecidimAssemblies < ActiveRecord::Migration[6.0]
  def change
    add_column :decidim_assemblies, :decidim_user_group_id, :integer
    add_index :decidim_assemblies, :decidim_user_group_id
  end
end
