require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  unless ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails' do
      coverage_dir 'coverage/rspec'
    end
  end
  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  # require 'factory_girl'
  #require 'capybara/rspec'
  #require 'capybara/rails'
  require "cancan/matchers"


  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  # Dir.glob(File.dirname(__FILE__) + "/factories/*.rb").each do |factory|
  #    require factory
  # end

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    #  config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    #  config.use_transactional_fixtures = true
    config.include Devise::TestHelpers, type: :controller
    config.include FactoryGirl::Syntax::Methods
    config.include Mongoid::Matchers
    config.before(:each) do
      DatabaseCleaner.orm = "mongoid" 
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean
    end
  end
end

Spork.each_run do
  if ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails' do
      coverage_dir 'coverage/rspec'
    end
  end
  ActiveSupport::Dependencies.clear
  ActiveRecord::Base.instantiate_observers
  FactoryGirl.reload
  Dir["#{Rails.root}/app/controllers/*.rb"].each do |controller|
    load controller
  end
  Dir["#{Rails.root}/app/models/*.rb"].each do |model|
    load model
  end
end






