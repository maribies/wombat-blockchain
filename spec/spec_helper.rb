ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start do
  enable_coverage :branch
  add_filter "/spec/"
end

# in large part, modified from capybara-3.35.3/lib/capybara/rspec.rb
require 'rspec/core'
require 'capybara/dsl'
require 'capybara/rspec/matchers'
require 'capybara/rspec/matcher_proxies'
require 'super_diff/rspec'

require 'blockchain/app'
Capybara.app = Blockchain::App

module FeatureHelpers
  def page
    Capybara.current_session
  end
end


RSpec.configure do |config|
  config.include Capybara::RSpecMatchers, type: :feature
  config.include FeatureHelpers, type: :feature

  config.before type: :feature do |example|
    Capybara.current_driver = Capybara.javascript_driver if example.metadata[:js]
    Capybara.current_driver = example.metadata[:driver] if example.metadata[:driver]
  end

  config.after type: :feature do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

