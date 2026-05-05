# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Support (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*ENV.fetch(
      "CORS_ALLOWED_ORIGINS",
      "http://localhost:8081,http://127.0.0.1:8081,http://localhost:19006,http://127.0.0.1:19006,http://localhost:3000,http://127.0.0.1:3000"
    ).split(",").map(&:strip))

    # Active Storage blob routes must be accessible for image uploads/downloads
    resource "/rails/active_storage/*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ["Authorization"],
      credentials: false

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ["Authorization"],
      credentials: false
  end
end
