This document provides technical information about the design of this test kit
and is intended to serve multiple purposes:
* To guide individuals who are interested in contributing to this project.
* To assist in the onboarding of new development team members.
* To support the long-term continuity of this project by enabling an
  effective transfer of this software to new stewards.

This document does not provide detailed instructions on how to use
an Inferno test kit, the contents of the (g)(31) Certification Criterion,
basics of the Inferno Framework, or details on how to use Ruby, Docker,
or other tools. Developers are expected to have at least a basic understanding
of all these topics.

Please note that the focus of this document is on features that are specific to
this test kit and it does not provide a detailed explanation of common Inferno
Framework functionality.

## Test Design Principles and features

Prior to making any updates or additions to these tests, developers should
be aware of the general principles that guided development of the existing tests
to ensure a consistent test experience for users. While judgment is required
by the test developer to determine the appropriate level of testing for each
requirement, it is important to provide a consistent approach across the entire
test kit to aid users in understanding the results of the tests.

Tests for this test kit have been designed with the following principles:
* Easy testing: Users should be able to run the tests with minimal input or
  configuration, and tests should complete in a reasonable amount of time.
* Limit extraneous constraints: The tests should not place additional constraints
  on the system under test.
* Reuse existing tests when possible: Reuse tests from test kits that target
  implementation guides that are required within this test kit.

The design of the tests within this test kit reflects these principles:
* Systems do not need to load a specific set of example data; instead, the
  tests allow systems to provide their own data that exhibits all required
  functionality.
* Tests are written to verify the use of all required specifications together
  as described by the certification criterion, instead of requiring systems to
  independently test each.
* When a test involves multiple standards, they are written intelligently
  so that only the versions of the standard that were selected by the
  tester apply.
* Not all requirements provided by the certification criterion or the
  underlying standards can be tested using an automated tool. In these cases,
  the system under test can attest that the requirement is met, or a tester
  can choose to provide a method for visual inspection. Tests are provided
  at the end of the test kit to ensure these are accomplished.

The (g)(31) Test Kit manages this complexity through standard software design
practices and approaches, leveraging the functionality provided by the Ruby
programming language. While this code is intended to be accessible to
developers new to the Ruby language, developers are expected to learn the basics
of Ruby development before attempting to alter these tests. This test kit also
uses RSpec to "unit test" components of these tests, and developers are expected
to learn the basics of RSpec as well.

## Relationship with Other Test Kits

The ONC (g)(31) Certification Criterion requires the implementation of several
FHIR Implementation Guides, while providing guidance on how to support these
implementation guides to accomplish the specific requirements of the certification
criterion. In order to facilitate testing systems independently of the (g)(31)
Certification requirements, each of these Implementation Guides also has a
stand-alone test kit. The (g)(31) Test Kit then imports tests defined in these
test kits and integrates them into a single cohesive test procedure, while also
further constraining their implementation to meet any (g)(31)-specific
requirements.

The specific test kits that are imported into this test kit include:

1. **[Da Vinci CRD Test Kit](https://github.com/inferno-framework/davinci-crd-test-kit)**:
   Most (g)(31) tests are imported directly from the CRD test kit.
1. **[US Core Test Kit](https://github.com/inferno-framework/us-core-test-kit)**:
   The CRD test kit uses US Core tests which are in turn imported into (g)(31).

### Importing CRD Client Tests

The CRD client groups are pulled into the suite with Inferno's `group from:`
and `test from:` DSL. The imported groups and tests are then passed through
`G31CRDImport.import!`, defined in
`lib/onc_certification_g31_test_kit/g31_crd_import.rb`, which adapts them in
three ways:

* **Optional runnables are removed.** `exclude_optional: true` only drops the
  direct children of the imported group, so `import!` removes optional
  runnables at every level below it.
* **CRD URLs point at this suite.** The CRD endpoints are registered by this
  suite under a CRD version prefix (`/crd_v221`) so that a later CRD version
  can be added alongside it. Imported tests get `G31ClientURLs`, so the URLs
  they build at run time resolve to these endpoints rather than the CRD client
  suite's. URLs in static text, as described below, are rewritten as well.
* **Static text describes the Health IT Module.** In titles, short titles,
  descriptions and input instructions of runnables, and in titles and
  descriptions of inputs, CRD client suite URLs are replaced with this
  suite's, and singular references to "CRD client" become "Health IT Module".
  Plural "CRD clients" is left alone, because it refers to CRD clients in
  general, not the system under test.

Only the static text is rewritten. Messages produced while the tests run, such
as assertion failures, skip reasons and error messages, come from the CRD test
kit unchanged and may still refer to the system under test as the "CRD client".
This is intentional: in these tests the Health IT Module is acting as a CRD
client, so the term remains accurate, and the CRD test kit should keep the
terminology of its own implementation guide. Rewriting these messages would
depend on how the Inferno test runner collects results internally, which is not
a supported extension point.

After all groups are imported, `G31Requirements.apply!`, defined in
`lib/onc_certification_g31_test_kit/g31_requirements.rb`, adds the
§ 170.315(g)(31) and § 170.315(j)(20) requirements to the imported runnables
that verify them, alongside the CRD implementation guide requirements they
already declare.

The specs in `spec/onc_certification_g31_test_kit/g31_certification_suite_spec.rb`
and `g31_requirements_spec.rb` check each of these steps against the imported
suite. Run them after updating the CRD test kit version to catch anything a new
release adds that these steps don't handle.

## Test Kit Code Organization

The (g)(31) Test Kit follows general Ruby conventions for applications and
libraries. It is organized into several main directories:

- `.github`: Contains workflows for integrating with GitHub's automated tools
- `config`: Contains configuration files for the test kit, including presets
- `data`: Contains runtime data for the test kit, such as local database files
- `docs`: Contains documentation for this test kit
- `execution_scripts`: Contains integrated testing scripts
- `lib`: Contains the main logic for the test kit, including the test cases and helper functions
- `lib/onc_certification_g31_test_kit`: Contains the main tests for the test kit
- `spec`: Contains the RSpec test cases for the test kit
- `tmp`: Temporary files used by the test kit at runtime

The (g)(31) Test Kit contains a single suite of tests, which is capable of
testing any valid combination of approved standards for certification. This
suite is defined in
`lib/onc_certification_g31_test_kit/g31_certification_suite.rb` and imports all
necessary tests from both external test kits and from within the (g)(31) Test
Kit itself.

## Testing Code Changes

This test kit includes "self testing" functionality to provide
confidence that the tests perform as expected. Prior to committing changes to
this test kit, developers should ensure that both RSpec tests and End-to-End
tests pass.

### RSpec Tests

The test kit contains many "unit" tests within the `spec` directory. These
tests are written in RSpec, and can be run with the following command:

```
bundle exec rake
```

These tests should be run after any changes to the tests, and must pass before
any changes to the tests are merged into the main branch. It is not expected
that the code base achieves 100% test coverage; instead, the team has followed a
common sense approach to testing components that 1) are complicated or 2) are
likely to change.

### End-to-End testing

Besides the unit tests provided within this test kit, after each update
the tests should be validated against a complete client implementation
that is known to be correct. At this time, two systems can support partial
end-to-end testing:
- The Da Vinci BR Provider Reference Implementation: See the [Walkthrough](Walkthrough) for
  instructions on how to execute a publicly-hosted copy of this test kit
  against the public BR Provider RI. This execution is not expected
  to fully pass at this time.
- The Inferno CRD Server v2.2.1 Suite: To run a smoke test of the (g)(31)
  suite's order-sign interaction and validation against the Inferno CRD
  Server v2.2.1 Suite, including in a local environment, perform the
  following steps:
  1. Create a CRD Server v2.2.1 session by navigating to `<inferno-base>/davinci_crd`
  (e.g., http://localhost:4567/davinci_crd), selecting "Da Vinci CRD Server
  v2.2.1 Test Suite", and clicking "Start Testing".
  1. Select the "Run Against the (g)(31) Suite" preset.
  1. Run group "1 Discovery" and confirm that all pass (NOTE: if running locally
  without TLS setup, test "1.01 CRD server uses TLS 1.2 or higher" is expected
  to fail).
  1. In another tab, create a (g)(31) session by navigating to `<inferno-base>/onc_certification_g31`,
  (e.g., http://localhost:4567/onc_certification_g31), selecting any version of
  US Core, and clicking "Start Testing".
  1. Select the "Run Against the CRD Server Suite" preset.
  1. Run group "1.2.1 order-sign" without any changes to inputs.
  1. When the "User Action Required" dialog appears, switch to the CRD Server Suite
     tab and run group "3.4 order-sign" without any changes to inputs.
  1. When the server group has completed, return to the (g)(31) tab,
     click the link indicating all requests have been made, and attest to the
     display of the coverage-information response in the "User Action Required"
     dialog that appears next. The run will complete ending the smoke test.
  1. Review the results: The server tests should all pass and the client tests
     will mostly pass with the exception of:
     - Test "1.2.1.3.01 Hook requests have the correct structure and contents",
       which fails due to invalid request content sent intentionally by the
       server suite.
     - Test "1.2.1.3.08 Hook request interactions use TLS" will fail when run
       locally without TLS.

## FHIR and Terminology Validation

To allow test developers control of terminology validation, the public version of
this test kit relies on a private terminology server. The terminology server used
is governed by the `G31_TERMINOLOGY_SERVER` environment variable.
