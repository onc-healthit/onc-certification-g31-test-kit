# onc-certification-g31-test-kit

The ONC Certification (g)(31) Coverage Requirements Discovery API Test Kit is a testing tool for
Health IT systems seeking to meet the requirements of the § 170.315(g)(31)
certification criterion in the ONC Health IT Certification Program.

DISCLAIMER: this test kit is currently a draft and not ready for ONC certification purposes.

This test kit is built using the [Inferno
Framework](https://inferno-framework.github.io/).

## Getting Started

- Install [Ruby 3.3+](https://www.ruby-lang.org/en/documentation/installation/)
  and the [`bundler` gem](https://bundler.io/).
- Run `bundle install` to install dependencies.
- Run `bundle exec inferno migrate` to set up the database.
- Run `bundle exec inferno services start` to start the background services.
- Run `bundle exec inferno start` to start the server.
- Navigate to `http://localhost:4567` to access the test kit.

Alternatively, with Docker installed, run `setup.sh` and then `run.sh`, then
navigate to `http://localhost`.
