source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.2.0'

# Core Rails
gem 'rails', '~> 7.1.0'
gem 'pg', '~> 1.5'
gem 'puma', '~> 6.4'

# Multi-tenancy
gem 'acts_as_tenant', '~> 0.4'

# Background jobs
gem 'sidekiq', '~> 7.2'
gem 'redis', '~> 5.0'

# API
gem 'rack-cors'
gem 'jbuilder', '~> 2.11'

# Authentication & Authorization
gem 'bcrypt', '~> 3.1.7'
gem 'jwt', '~> 2.7'

# HTTP client for LLM APIs
gem 'faraday', '~> 2.9'
gem 'faraday-retry', '~> 2.2'

# Utilities
gem 'dotenv-rails', '~> 3.0'

group :development, :test do
  gem 'rspec-rails', '~> 6.1.0'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'faker', '~> 3.2'
  gem 'pry-rails', '~> 0.3'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
end

group :test do
  gem 'shoulda-matchers', '~> 6.0'
  gem 'webmock', '~> 3.20'
  gem 'vcr', '~> 6.2'
  gem 'database_cleaner-active_record', '~> 2.1'
end

group :development do
  gem 'annotate', '~> 3.2'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false
