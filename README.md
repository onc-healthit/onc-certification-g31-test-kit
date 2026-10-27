# ONC Certification (g)(31) Coverage Requirements Discovery API Test Kit

The ONC Certification (g)(31) Coverage Requirements Discovery API Test Kit is a testing tool for
Health IT Modules seeking to meet the requirements of the
[Coverage Requirements Discovery criterion § 170.315(g)(31)](https://healthit.gov/test-method/provider-prior-authorization-api-coverage-requirements-discovery)
in the ONC Health IT Certification Program.

This test kit evaluates a provider system acting as a Da Vinci Coverage Requirements Discovery
(CRD) client. Inferno simulates CRD servers that the Health IT Module invokes using CDS Hooks,
and then verifies the Health IT Module's US Core FHIR API. Tests cover:

*   Da Vinci Coverage Requirements Discovery (CRD) Implementation Guide (v2.2.1)
*   CDS Hooks (v3.0.0-ballot) and the CDS Hooks Library (v1.0.1)
*   US Core Implementation Guide (v3.1.1, v6.1.0, or v7.0.0)

This test kit is built using the [Inferno Framework](https://inferno-framework.github.io/).

## Using this Test Kit

A hosted instance of this test kit is available on the
[ONC-hosted Inferno instance](https://inferno.healthit.gov/suites/g31_certification).

Documentation is available on the [project wiki](https://github.com/onc-healthit/onc-certification-g31-test-kit/wiki):

*   [Test Kit Walkthrough](https://github.com/onc-healthit/onc-certification-g31-test-kit/wiki/Walkthrough):
    A step-by-step guide to running the tests, including a demonstration against the publicly
    available Da Vinci Burden Reduction (BR) Provider reference implementation.
*   [Technical Overview](https://github.com/onc-healthit/onc-certification-g31-test-kit/wiki/Technical-Overview):
    Design and implementation details for developers contributing to this test kit.

## Getting Started

To run this test kit locally:

- Install [Ruby 3.3+](https://www.ruby-lang.org/en/documentation/installation/)
  and the [`bundler` gem](https://bundler.io/).
- Run `bundle install` to install dependencies.
- Run `bundle exec inferno migrate` to set up the database.
- Run `bundle exec inferno services start` to start the background services.
- Run `bundle exec inferno start` to start the server.
- Navigate to `http://localhost:4567` to access the test kit.

Alternatively, with Docker installed, run `setup.sh` and then `run.sh`, then
navigate to `http://localhost`.

## Support

For questions or issues with this test kit, please reach out to the Inferno team on the
[#Inferno FHIR Zulip channel](https://chat.fhir.org/#narrow/stream/179309-inferno).

Report bugs or provide suggestions in
[GitHub Issues](https://github.com/onc-healthit/onc-certification-g31-test-kit/issues).

## License

This test kit is licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) and
[NOTICE.md](NOTICE.md) for details.
