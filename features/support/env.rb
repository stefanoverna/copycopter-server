require 'rubygems'

require 'cucumber/rails'
Capybara.default_selector = :css
Capybara.save_and_open_page_path = 'tmp'
Capybara.javascript_driver = :webkit
Capybara.ignore_hidden_elements = false
$LOAD_PATH << Rails.root.join('spec', 'support').to_s

ActionController::Base.allow_rescue = false
Cucumber::Rails::World.use_transactional_fixtures = true
require 'database_cleaner'
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean

