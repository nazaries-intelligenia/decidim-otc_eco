# frozen_string_literal: true

Decidim.configure do |config|
  config.maps = {
    provider: (ENV["MAPS_PROVIDER"] || "osm").to_sym,
    api_key: ENV["MAPS_DYNAMIC_API_KEY"] || ENV.fetch("MAPS_API_KEY", nil),
    dynamic: {
      tile_layer: {
        url: ENV["MAPS_DYNAMIC_URL"] || "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        api_key: ENV["MAPS_DYNAMIC_API_KEY"].present?,
        attribution: (ENV["MAPS_ATTRIBUTION"] ||
          %(<a href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap</a> contributors)).dup,
        extra_vars: ENV.fetch("MAPS_EXTRA_VARS", nil)
      }
    },
    static: (ENV["MAPS_STATIC_URL"].present? ? { url: ENV["MAPS_STATIC_URL"] } : nil),
    geocoding: {
      host: ENV["MAPS_GEOCODING_HOST"] || "nominatim.openstreetmap.org",
      use_https: ENV.fetch("MAPS_GEOCODING_USE_HTTPS", "true") == "true"
    },
    autocomplete: {
      url: ENV["MAPS_AUTOCOMPLETE_URL"] || "https://photon.komoot.io/api/"
    }
  }.compact
end
