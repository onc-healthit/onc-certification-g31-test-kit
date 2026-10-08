# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# TODO: switch to the rubygems release
gem 'davinci_crd_test_kit',
    git: 'https://github.com/inferno-framework/davinci-crd-test-kit.git',
    branch: 'id-262-requirements-coverage'

group :development, :test do
  gem 'debug'
  gem 'rubocop', '~> 1.9'
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'database_cleaner-sequel', '~> 1.8'
  gem 'factory_bot', '~> 6.1'
  gem 'rack-test'
  gem 'rspec', '~> 3.10'
  gem 'simplecov', '0.21.2', require: false
  gem 'webmock', '~> 3.11'
end