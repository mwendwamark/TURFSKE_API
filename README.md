# TURFSKE_API

Rails 8 API backend for the TURFSKE application with JWT authentication via Devise.

## System Requirements

### Operating System
- Linux (Ubuntu 20.04+ recommended) or macOS

### Required System Packages
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  libpq-dev \
  postgresql \
  postgresql-contrib \
  git \
  curl \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  autoconf \
  bison \
  libyaml-dev \
  libncurses5-dev \
  libffi-dev \
  libgdbm-dev
```

### Required Tools
| Tool | Version | Installation |
|------|---------|--------------|
| Ruby | 3.2.3 | Use [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io) |
| PostgreSQL | 18.3+ | `sudo apt-get install postgresql postgresql-contrib` |
| Bundler | latest | `gem install bundler` |
| Git | latest | `sudo apt-get install git` |

### Ruby Version Management (rbenv)
```bash
# Install rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# Install ruby-build plugin
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# Install Ruby 3.2.3
rbenv install 3.2.3
rbenv global 3.2.3
rbenv rehash
```

## Project Dependencies

### Ruby Gems (from Gemfile)

**Core:**
- `rails 8.0.5` - Web framework
- `pg ~> 1.1` - PostgreSQL adapter
- `puma >= 5.0` - Web server
- `bootsnap` - Boot time optimization

**Authentication & API:**
- `devise ~> 4.9` - Authentication
- `devise-jwt ~> 0.11` - JWT token authentication
- `jsonapi-serializer` - JSON API serialization
- `rack-cors` - CORS handling

**Rails Solid Components:**
- `solid_cache` - Database-backed caching
- `solid_queue` - Background job processing
- `solid_cable` - WebSocket cable

**Optional/Deployment:**
- `kamal` - Docker deployment
- `thruster` - HTTP caching/compression

**Development & Test:**
- `debug` - Debugging
- `brakeman` - Security scanning
- `rubocop-rails-omakase` - Code style

Full dependency tree is in `Gemfile.lock`.

## Setup Instructions

### 1. Clone & Navigate
```bash
git clone <repository-url>
cd TURFSKE/TURFSKE_API
```

### 2. Install Ruby Version
```bash
rbenv install 3.2.3  # if not already installed
rbenv local 3.2.3
```

### 3. Install Gems
```bash
gem install bundler
bundle install
```

### 4. PostgreSQL Setup
```bash
# Start PostgreSQL service
sudo service postgresql start

# Create PostgreSQL user (if needed)
sudo -u postgres createuser -s $USER
sudo -u postgres psql -c "ALTER USER $USER WITH PASSWORD 'your_password';"

# Or set password for postgres user
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"
```

### 5. Environment Configuration
Create `.env` file in project root (do not commit):
```bash
DATABASE_URL=postgresql://localhost/turfske_api_development
RAILS_ENV=development
```

Or set these in your shell profile.

### 6. Database Setup
```bash
# Create databases
rails db:create

# Run migrations
rails db:migrate

# Seed data (if available)
rails db:seed
```

### 7. Run the Server
```bash
rails server -p 3000
```

Server will be available at `http://localhost:3000`

## Configuration Files

| File | Purpose |
|------|---------|
| `config/database.yml` | Database configuration (PostgreSQL) |
| `config/credentials.yml.enc` | Encrypted credentials (edit with `rails credentials:edit`) |
| `config/master.key` | Decryption key (keep secret!) |
| `config/initializers/cors.rb` | CORS settings |
| `config/initializers/devise.rb` | Devise configuration |
| `config/puma.rb` | Puma server configuration |

## Services Required

- **PostgreSQL** - Must be running (`sudo service postgresql start`)

## Running Tests

```bash
rails test
```

## Troubleshooting

**PostgreSQL connection error:**
```bash
sudo service postgresql status
sudo service postgresql start
```

**Gem install errors:**
```bash
bundle clean --force
bundle install
```

**Ruby version mismatch:**
```bash
rbenv versions
rbenv local 3.2.3
```

## Deployment

This application supports deployment via [Kamal](https://kamal-deploy.org).
Configuration is in `config/deploy.yml`.
