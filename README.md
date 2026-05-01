# TURFSKE_API

Rails 8 API backend for the TURFSKE application with JWT authentication.

## Prerequisites

- Ruby 3.2.3
- PostgreSQL
- Bundler

## System Dependencies

### Ruby Gems
- **Rails 8.0.5** - Web framework
- **PostgreSQL (pg ~> 1.1)** - Database
- **Puma (>= 5.0)** - Web server
- **Devise (~> 4.9)** - Authentication
- **Devise-JWT (~> 0.11)** - JWT token authentication
- **jsonapi-serializer** - JSON API serialization
- **rack-cors** - Cross-Origin Resource Sharing
- **solid_cache** - Database-backed caching
- **solid_queue** - Background job processing
- **solid_cable** - WebSocket cable
- **bootsnap** - Boot time optimization
- **kamal** - Docker deployment (optional)
- **thruster** - HTTP caching/compression for Puma

### Development/Test Gems
- debug
- brakeman (security scanning)
- rubocop-rails-omakase (code style)

## Setup Instructions

1. Clone the repository and navigate to the API directory:
   ```bash
   cd TURFSKE_API
   ```

2. Install Ruby gems:
   ```bash
   bundle install
   ```

3. Configure environment variables (create `.env` file if needed):
   - `DATABASE_URL` - PostgreSQL connection string
   - `JWT_SECRET_KEY` - Secret key for JWT tokens

4. Database setup:
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed  # if seeds exist
   ```

5. Start the server:
   ```bash
   rails server -p 3000
   ```

## Configuration

- CORS settings: Configure in `config/initializers/cors.rb`
- Devise JWT: Configure in `config/initializers/devise.rb`

## Running Tests

```bash
rails test
```

## Deployment

This app supports deployment via [Kamal](https://kamal-deploy.org). See `config/deploy.yml` for configuration.
