# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# TODO: switch to the rubygems release once one exists that includes the CRD client v2.2.1
# attestation group. That group landed on CRD main after v0.14.1, the latest published version,
# so it is only reachable from git. This kit cannot be published to rubygems until then
gem 'davinci_crd_test_kit',
    git: 'https://github.com/inferno-framework/davinci-crd-test-kit.git',
    branch: 'main'
gem 'us_core_test_kit', git: 'https://github.com/inferno-framework/us-core-test-kit.git',
    branch: 'main'

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