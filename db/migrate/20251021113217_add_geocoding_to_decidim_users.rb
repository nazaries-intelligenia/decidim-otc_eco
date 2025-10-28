class AddGeocodingToDecidimUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_users, :address, :text, null: true
    add_column :decidim_users, :latitude, :decimal, precision: 10, scale: 6, null: true
    add_column :decidim_users, :longitude, :decimal, precision: 10, scale: 6, null: true

    add_index :decidim_users, [:latitude, :longitude],
              name: "index_decidim_users_on_lat_lng",
              where: "latitude IS NOT NULL AND longitude IS NOT NULL"

    expression = %q{
      (type = 'Decidim::UserGroup')
      OR (address IS NULL AND latitude IS NULL AND longitude IS NULL)
    }.squish

    add_check_constraint :decidim_users, expression,
                         name: "decidim_users_geocoding_only_for_user_groups"
  end
end
