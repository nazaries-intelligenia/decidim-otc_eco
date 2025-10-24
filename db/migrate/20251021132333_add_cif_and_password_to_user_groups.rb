class AddCifAndPasswordToUserGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_users, :cif, :string
    add_column :decidim_users, :datadis_password, :string
  end
end
