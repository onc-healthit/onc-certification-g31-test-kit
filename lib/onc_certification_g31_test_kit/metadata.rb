require_relative 'version'

module ONCCertificationG31TestKit
  class Metadata < Inferno::TestKit
    id :onc_certification_g31_test_kit
    title 'ONC Certification (g)(31) Standardized API Test Kit'
    description <<~DESCRIPTION
      The ONC Certification (g)(31) Standardized API Test Kit is a testing tool for
      Health IT systems seeking to meet the requirements of the Coverage Requirements
      Discovery criterion § 170.315(g)(31) in the ONC Health IT Certification Program.
      <!-- break -->

      Systems may adopt later versions of standards than those named in the rule as
      approved by the ONC Standards Version Advancement Process (SVAP).

      Please select which approved version of US Core to use, and click 'Create Test
      Session' to begin testing.

      ## Status

      The ONC Certification (g)(31) Standardized API is actively developed and updates are released monthly.

      The test kit currently tests requirements for the [Coverage Requirements
      Discovery criterion §
      170.315(g)(31)](https://healthit.gov/test-method/provider-prior-authorization-api-coverage-requirements-discovery).
      This includes:
      - Coverage discovery
      - Registration
      - order-sign CDS Hooks support
      - CRD Client capabilities
      - Documentation

      See the test descriptions within the test kit for detail on the specific
      validations performed as part of testing these requirements.

      ## Repository and Resources

      The ONC Certification (g)(31) Standardized API Test Kit can be [downloaded from
      its GitHub
      repository](https://github.com/onc-healthit/onc-certification-g31-test-kit),
      where additional resources and documentation are also available to help users
      get started with the testing process. The
      [Releases](https://github.com/onc-healthit/onc-certification-g31-test-kit/releases)
      page provides information about each new release.

      ## Providing Feedback and Reporting Issues

      We welcome feedback on the tests, including but not limited to the following areas:

      - Validation logic, such as potential bugs, lax checks, and unexpected failures.
      - Requirements coverage, such as requirements that have been missed, tests that
        necessitate features that the IG does not require, or other issues with the
        interpretation of the IG's requirements.
      - User experience, such as confusing or missing information in the test UI.

      Please report any issues with this set of tests in the [issues
      section](https://github.com/onc-healthit/onc-certification-g31-test-kit/issues)
      of the repository.
    DESCRIPTION

    suite_ids [:g31_certification]
    tags ['Da Vinci', 'CRD', 'US Core']
    last_updated LAST_UPDATED
    version VERSION
    maturity 'Low'
    authors ['Inferno Team']
    repo 'https://github.com/onc-healthit/onc-certification-g31-test-kit'
  end
end
