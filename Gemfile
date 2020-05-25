source 'https://rubygems.org'
ruby '2.4.0'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.2'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.0'

gem 'thor', '0.19.1'

# --------------------------------------------------

# User management
gem 'devise'
gem 'devise_token_auth'
gem 'activeadmin', github: 'activeadmin'
gem 'inherited_resources', github: 'activeadmin/inherited_resources'

# Cross-origin resource sharing
gem 'rack-cors', require: 'rack/cors'

gem 'health_check'
gem 'lograge'
gem 'dotenv'

# Enumerated attributes
gem 'enumerize'

gem 'airbrake', '~> 5.0'

gem 'paperclip'
gem 'delayed_paperclip'
gem 'aws-sdk', '~> 2'

# Annotate model and routes
gem 'annotate'

# API documentation
gem 'apipie-rails', github: 'Apipie/apipie-rails'

# Pagination
gem 'kaminari'

# Squeel-like query DSL for Active Record
gem 'baby_squeel'

gem 'slack-notifier'

# Soft delete for records
gem 'paranoia'

# iOS push notifications
gem 'houston'

gem 'interactor'

gem 'slim'

gem 'pluck_each'

# devise translation for arabic language
gem 'devise-i18n'

# Sidekiq
gem 'sidekiq'
gem 'sinatra', require: nil
gem 'sidekiq-failures'  # track of sidekiq failed jobs
gem 'sidekiq-symbols'   # named params and symbols support
gem 'sidekiq-cron'      # scheduling add-on
gem 'sidekiq-statistic' # display of statistics for workers
gem 'sidekiq-status' # statuses of sidekiq jobs
gem 'redis-namespace'

gem 'geocoder'
gem 'google_maps_service'

gem 'twitter'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri

  gem 'pry-rails'
  gem 'pry-byebug'

  # Test framework
  gem 'rspec-rails'

  # Testing fixtures
  gem 'factory_girl_rails'

  # RSpec formatter that uses a progress bar instead of a string of letters and dots as feedback
  gem 'fuubar', require: false

  # A library for generating fake data
  gem 'faker'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Errors helpers
  gem 'better_errors'
  gem 'binding_of_caller'

  # Pretty prints ruby objects with ap command
  gem 'awesome_print'

  # CTAGS
  gem 'gem-ctags'

  # Preview email in the default browser instead of sending it
  gem 'letter_opener'

  # Default translations for rails
  gem 'i18n_generators'
end

group :test do
  # Code coverage analysis tool
  gem 'simplecov', require: false

  gem 'webmock'

  # Rspec helpers
  gem 'database_cleaner', require: false
  gem 'shoulda-matchers', require: false

  # API testing framework
  gem 'airborne', github: 'blddmnd/airborne', require: false

  # This gem brings back assigns to your controller tests
  gem 'rails-controller-testing'

  # Email matchers
  gem 'email_spec'
end
