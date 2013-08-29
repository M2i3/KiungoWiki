source 'https://rubygems.org'
ruby "2.0.0"

gem 'rails', '3.2.14'
gem "haml"
gem 'formtastic', github: 'justinfrench/formtastic', branch: '2.1-stable'
gem 'formtastic-bootstrap', github: 'cgunther/formtastic-bootstrap', branch: 'bootstrap2-rails3-2-formtastic-2-1'
gem "thin"
gem "mongoid", '~> 3.1.0'
gem 'mongoid-history', '~> 0.3.3'
#gem 'will_paginate', '>=3.0.pre'
gem 'acts-as-taggable-on'
# for pagination https://github.com/amatsuda/kaminari
gem 'kaminari'
# for access control
gem 'cancan' 
# for user registration and authentication
gem 'devise'
#gem 'devise_rpx_connectable'
# for text-to-html formatting
gem 'RedCloth'
gem 'mongoid_search', '~> 0.3.2'

gem "http_accept_language"

group :production do
  gem 'newrelic_rpm'
end

group :development do
  gem 'guard-bundler'
  gem 'roo', '~> 1.12.1'
  gem 'google-spreadsheet-ruby'
end

group :development, :test do
  gem 'foreman'
  gem 'guard', "~> 1.6.1"
  gem 'guard-cucumber', "~> 1.3.2"
  gem 'guard-rspec'
  gem 'guard-spork', "~> 1.4.1"
  gem 'rspec-rails'
  gem 'mongoid-rspec'
  gem 'database_cleaner'
  gem 'therubyracer'
  gem 'spork', "~> 1.0.0rc3"
  gem 'capybara', '~> 2.0.2'
  gem "capybara-webkit", "~> 0.14.2"
  gem 'cucumber'
  gem 'launchy'
  gem 'factory_girl_rails', "~> 4.2.0"
  gem 'rb-fsevent', '~> 0.9.3', require: false
  gem 'rb-inotify', require: false
end

group :test do
  gem 'cucumber-rails', '~> 1.3.0', require: false
  gem "capybara-screenshot"
  gem 'simplecov', require: false
end

group :assets do
  gem 'coffee-rails', '~> 3.2.1'
  gem 'yui-compressor'
  gem 'execjs'
  gem "jquery-rails", '~> 2.2.1'
  gem 'jquery-ui-rails', '~> 4.0.2'
  gem 'twitter-bootstrap-rails', github: 'seyhunak/twitter-bootstrap-rails'
end

