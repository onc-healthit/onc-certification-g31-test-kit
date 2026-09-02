require 'davinci_crd_test_kit'
require_relative 'metadata'
require_relative 'g31_options'
require_relative 'g31_crd_import'
require_relative 'documentation_attestation_test'
require_relative 'endpoints/g31_cds_services_discovery_handler'
require_relative 'endpoints/g31_hook_request_endpoint'

module ONCCertificationG31TestKit
  class G31CertificationSuite < Inferno::TestSuite
    id :g31_certification
    title 'ONC Certification (g)(31) Coverage Requirements Discovery API'
    short_title '(g)(31) CRD API'
    description %(
      The ONC Certification (g)(31) Coverage Requirements Discovery API Test Suite
      is a testing tool for Health Level 7 (HL7®) Fast Healthcare Interoperability
      Resources (FHIR®) clients seeking to meet the requirements of the
      [Coverage Requirements Discovery criterion § 170.315(g)(31)](https://healthit.gov/test-method/provider-prior-authorization-api-coverage-requirements-discovery)
      in the ONC Certification Program.

      **DISCLAIMER**: this test kit is currently a draft and not ready for ONC certification purposes.

      This test suite is organized into groups that in sum cover the
      requirements within the [§ 170.315(g)(31) certification
      criterion](https://healthit.gov/test-method/provider-prior-authorization-api-coverage-requirements-discovery/).
      The groups are intended to be run in order during certification testing, but can
      be run out of order to support testing during development or certification
      preparation. Some scenarios depend on data collected during previous
      groups to function. In these cases, the group description describes
      these dependencies.

      Additional details about executing the tests in this suite can be found in
      the [walkthrough](https://github.com/onc-healthit/onc-certification-g31-test-kit/wiki/Walkthrough)
      which describes how to execute these tests against a publicly available
      reference implementation.

      To get started, configure the Health IT Module to use Inferno's simulated
      CRD server by pointing it at the following CDS Hooks discovery endpoints
      and begin with the "Registration" group:

      * `#{G31CRDImport.base_url}#{DaVinciCRDTestKit::DISCOVERY_PATH}`
      * `#{G31CRDImport.base_url}#{DaVinciCRDTestKit::PREFETCH_DISCOVERY_PATH}`

      Systems must pass all tests to qualify for ONC certification.
    )

    suite_summary %(
      The ONC Certification (g)(31) Coverage Requirements Discovery API Test Kit is a testing tool
      for Health Level 7 (HL7®) Fast Healthcare Interoperability Resources
      (FHIR®) clients seeking to meet the requirements of the Coverage
      Requirements Discovery criterion § 170.315(g)(31) in the ONC Certification
      Program.

      Systems may adopt later versions of standards than those named in the rule
      as approved by the ONC Standards Version Advancement Process (SVAP). Please
      select which approved version of US Core to use, and click 'Create Test
      Session' to begin testing.
    )

    links [
      {
        label: 'Report Issue',
        url: 'https://github.com/onc-healthit/onc-certification-g31-test-kit/issues/'
      },
      {
        label: 'Open Source',
        url: 'https://github.com/onc-healthit/onc-certification-g31-test-kit/'
      },
      {
        label: 'Download',
        url: 'https://github.com/onc-healthit/onc-certification-g31-test-kit/releases'
      }
    ]

    # Allow the tester to select which US Core version to test against when
    # launching the suite
    suite_option :us_core_version,
                 title: 'US Core Version',
                 list_options: [
                   {
                     label: 'US Core 3.1.1',
                     value: G31Options::US_CORE_3
                   },
                   {
                     label: 'US Core 6.1.0',
                     value: G31Options::US_CORE_6
                   },
                   {
                     label: 'US Core 7.0.0',
                     value: G31Options::US_CORE_7
                   }
                 ]

    # Kept in sync with DaVinciCRDTestKit::V221::CRDClientSuite::CRD_MESSAGE_FILTERS (lines 62-138).
    # Copy and pasted here rather than referenced so that loading this suite does not also register the CRD suites.
    CRD_MESSAGE_FILTERS = [
      /\A\S+: \S+: URL value '.*' does not resolve/,
      %r{This element is not allowed by the profile http://hl7\.org/fhir/tools/StructureDefinition/CDSHooksExtensions\|1\.1\.2},
      /CDSHooksRequest.extension: Unrecognized property/,
      /No definition could be found for URL value/
    ].freeze

    US_CORE_3_MESSAGE_FILTERS = CRD_MESSAGE_FILTERS +
                                USCoreTestKit::USCoreV311::USCoreTestSuite::VALIDATION_MESSAGE_FILTERS

    US_CORE_6_MESSAGE_FILTERS = CRD_MESSAGE_FILTERS +
                                USCoreTestKit::USCoreV610::USCoreTestSuite::VALIDATION_MESSAGE_FILTERS

    US_CORE_7_MESSAGE_FILTERS = CRD_MESSAGE_FILTERS +
                                USCoreTestKit::USCoreV700::USCoreTestSuite::VALIDATION_MESSAGE_FILTERS

    requirement_sets(
      {
        identifier: '170.315(g)(31)_HTI-4',
        title: '170.315(g)(31) Coverage requirements discovery',
        actor: 'Provider'
      },
      {
        identifier: '170.315(j)(20)_HTI-4',
        title: '170.315(j)(20) Workflow triggers for decision support interventions—clients',
        actor: 'Client'
      },
      {
        identifier: 'hl7.fhir.us.davinci-crd_2.2.1',
        title: 'Da Vinci Coverage Requirements Discovery (CRD) v2.2.1',
        actor: 'CRD Client',
        requirements: 'billopt-1,conf-1,conf-3,conf-6,conf-10,conf-12,conf-13,dev-3-A,dev-12,dev-26,' \
                      'dev-28,dev-29-A,dev-30,dev-32,found-6,found-20,found-21,found-23,found-24,' \
                      'found-25-A,found-25-B,found-31,found-33,found-36-A,found-36-B,found-37,hook-1,' \
                      'hook-2-A,hook-2-B,hook-3,hook-7,hook-8,hook-20,hook-21,hook-24,hook-37,hook-39,' \
                      'impl-1,prof-3,prof-4,prof-5,prof-6,prof-7,prof-8,prof-9,prof-10,prof-11,prof-12,' \
                      'prof-13,resp-14,resp-46,resp-48,resp-49,sec-1,sec-2,sec-7'
      },
      {
        identifier: 'cds-hooks_3.0.0-ballot',
        title: 'CDS Hooks 3.0.0-ballot',
        actor: 'Client',
        requirements: '1-3,15,25,30,42,45-47,51,53,63,64,168,172-174,178,180-185,187,189-192,196,197,' \
                      '199,202,203,208,214,222-224,231,232,239,240,242'
      },
      {
        identifier: 'cds-hooks-library_1.0.1',
        title: 'CDS Hooks Library',
        actor: 'Client',
        requirements: 'referenced'
      },
      {
        identifier: 'hl7.fhir.us.core_3.1.1',
        title: 'US Core Implementation Guide v3.1.1',
        actor: 'Server',
        suite_options: {
          us_core_version: G31Options::US_CORE_3
        }
      },
      {
        identifier: 'hl7.fhir.us.core_6.1.0',
        title: 'US Core Implementation Guide v6.1.0',
        actor: 'Server',
        suite_options: {
          us_core_version: G31Options::US_CORE_6
        }
      },
      {
        identifier: 'hl7.fhir.us.core_7.0.0',
        title: 'US Core Implementation Guide v7.0.0',
        actor: 'Server',
        suite_options: {
          us_core_version: G31Options::US_CORE_7
        }
      }
    )

    fhir_resource_validator required_suite_options: G31Options::US_CORE_3_REQUIREMENT do
      igs(G31Options::CRD_V221_IG_PACKAGE)

      validation_context do
        snomedCT '731000124108'
        txServer ENV.fetch('G31_TERMINOLOGY_SERVER', 'https://tx.fhir.org/r4')
        displayWarnings true
      end

      exclude_message do |message|
        ['info', 'warning'].include?(message.type) ||
          US_CORE_3_MESSAGE_FILTERS.any? { |match_template| message.message.match?(match_template) }
      end
    end

    fhir_resource_validator required_suite_options: G31Options::US_CORE_6_REQUIREMENT do
      igs(G31Options::CRD_V221_IG_PACKAGE)

      validation_context do
        snomedCT '731000124108'
        txServer ENV.fetch('G31_TERMINOLOGY_SERVER', 'https://tx.fhir.org/r4')
        displayWarnings true
      end

      exclude_message do |message|
        ['info', 'warning'].include?(message.type) ||
          US_CORE_6_MESSAGE_FILTERS.any? { |match_template| message.message.match?(match_template) }
      end
    end

    fhir_resource_validator required_suite_options: G31Options::US_CORE_7_REQUIREMENT do
      igs(G31Options::CRD_V221_IG_PACKAGE)

      validation_context do
        snomedCT '731000124108'
        txServer ENV.fetch('G31_TERMINOLOGY_SERVER', 'https://tx.fhir.org/r4')
        displayWarnings true
      end

      exclude_message do |message|
        ['info', 'warning'].include?(message.type) ||
          US_CORE_7_MESSAGE_FILTERS.any? { |match_template| message.message.match?(match_template) }
      end
    end

    fhir_resource_validator :no_custom_extensions do
      igs(G31Options::CRD_V221_IG_PACKAGE)

      validation_context do
        snomedCT '731000124108'
        txServer ENV.fetch('G31_TERMINOLOGY_SERVER', 'https://tx.fhir.org/r4')
        displayWarnings true
        extensions []
      end

      exclude_message do |message|
        ['info', 'warning'].include?(message.type) ||
          CRD_MESSAGE_FILTERS.any? { |match_template| message.message.match?(match_template) }
      end
    end

    CRD_HOOK_PATHS = [
      DaVinciCRDTestKit::APPOINTMENT_BOOK_PATH,
      DaVinciCRDTestKit::ENCOUNTER_START_PATH,
      DaVinciCRDTestKit::ENCOUNTER_DISCHARGE_PATH,
      DaVinciCRDTestKit::ORDER_DISPATCH_PATH,
      DaVinciCRDTestKit::ORDER_SELECT_PATH,
      DaVinciCRDTestKit::ORDER_SIGN_PATH,
      DaVinciCRDTestKit::APPOINTMENT_BOOK_PREFETCH_SUBSET_PATH,
      DaVinciCRDTestKit::ENCOUNTER_START_PREFETCH_SUBSET_PATH,
      DaVinciCRDTestKit::ENCOUNTER_DISCHARGE_PREFETCH_SUBSET_PATH,
      DaVinciCRDTestKit::ORDER_DISPATCH_PREFETCH_SUBSET_PATH,
      DaVinciCRDTestKit::ORDER_SELECT_PREFETCH_SUBSET_PATH,
      DaVinciCRDTestKit::ORDER_SIGN_PREFETCH_SUBSET_PATH
    ].freeze

    CRD_DISCOVERY_PATHS = [
      DaVinciCRDTestKit::DISCOVERY_PATH,
      DaVinciCRDTestKit::PREFETCH_DISCOVERY_PATH
    ].freeze

    # The CRD IG version lives in a path prefix rather than in the suite id, so this stays a single
    # suite as more versions are added
    CRD_V221_PREFIX = G31Options::CRD_V221_PREFIX

    CRD_DISCOVERY_PATHS.each do |path|
      route :get, CRD_V221_PREFIX + path, G31CDSServicesDiscoveryHandler
    end

    allow_cors(*(CRD_HOOK_PATHS + CRD_DISCOVERY_PATHS).map { |path| CRD_V221_PREFIX + path })

    CRD_HOOK_PATHS.each do |path|
      suite_endpoint :post, CRD_V221_PREFIX + path, G31HookRequestEndpoint
    end

    def self.extract_token_from_query_params(request)
      request.query_parameters['token']
    end

    resume_test_route :get, CRD_V221_PREFIX + DaVinciCRDTestKit::RESUME_PASS_PATH do |request|
      G31CertificationSuite.extract_token_from_query_params(request)
    end
    resume_test_route :get, CRD_V221_PREFIX + DaVinciCRDTestKit::RESUME_FAIL_PATH, result: 'fail' do |request|
      G31CertificationSuite.extract_token_from_query_params(request)
    end

    G31CRDImport.import!(
      group do
        id :g31_hook_invocation
        title 'Hook Invocation'
        description %(
          During these tests, Inferno will simulate a CRD server for the Health IT Module
          to interact with. The Health IT Module must
          1. Register with both of Inferno's simulated CRD servers.
          2. Discover the capbilities of Inferno's CDS services.
          3. Make order-sign hook requests demonstrating conformance to CRD client
             requirements across a variety of scenarios.

          Sub-group execution order notes:
          - The "Registration" group must be run first. It records the connection details
            that the remaining groups use to associate incoming hook requests with
            this test session.
          - The "Cross Hook" group must be run after the "order-sign" group as requests
            made during that group will be analyzed.
          - Sub-groups under the "Scenarios" groups can be run at any time because
            requests made during these tests are not included in the cross hook analysis.
        )

        group from: :crd_v221_client_registration, exclude_optional: true

        group from: :crd_v221_client_hooks do
          description %(
            This group contain a sub-group which verifies the ability of the client to make and
            react to responses from the order-sign required by the
            [Coverage Requirements Discovery criterion § 170.315(g)(31)](https://healthit.gov/test-method/provider-prior-authorization-api-coverage-requirements-discovery)
            * [order-sign](https://hl7.org/fhir/us/davinci-crd/2.2.1/en/hooks.html#order-sign)

            The hook-specific group follows a standard hook verification pattern:
            1. Allow the client to make hook invocations for the tested hook, waiting until the tester indicates
               that all desired requests have been made, then
            2. Check the requests and their associated responses for conformance to (g)(31), CRD, and CDS Hooks
               requirements. Additionally, ask the tester to confirm that the responses were displayed
               appropriately by the client.

            Inferno simulates two CRD discovery endpoints, each with an order-sign service endpoint
            but with different service ids:
            - Discovery endpoint for services requesting the complete [standard prefetch data set](https://hl7.org/fhir/us/davinci-crd/2.2.1/en/foundation.html#standard-prefetch):
              `#{DaVinciCRDTestKit::V221::ClientURLs.discovery_url}`
              * `order-sign` service id: `order-sign-service`
            - Discovery endpoint for services requesting the a subset of the [standard prefetch data set](https://hl7.org/fhir/us/davinci-crd/2.2.1/en/foundation.html#standard-prefetch):
              `#{DaVinciCRDTestKit::V221::ClientURLs.prefetch_subset_discovery_url}`
              * `order-sign` service id: `order-sign-subset`
          )

          order_sign = groups.find { |group| group.id.to_s.include?('crd_v221_client_order_sign') }
          order_sign.required

          order_sign.config(
            inputs: {
              order_sign_selected_response_types: {
                default: ['coverage_information'],
                locked: true,
                options: {
                  list_options: [
                    {
                      label: 'Coverage Information',
                      value: 'coverage_information'
                    }
                  ]
                }
              }
            }
          )
        end

        group from: :crd_v221_client_scenarios, exclude_optional: true
        group from: :crd_v221_client_cross_hook, exclude_optional: true
      end
    )

    G31CRDImport.import!(group(from: :crd_v221_client_fhir_api, exclude_optional: true))

    G31CRDImport.import!(
      group(from: :crd_v221_client_attestations, exclude_optional: true) do
        crd_description = description
        description <<~DESCRIPTION
          #{crd_description.strip}

          These tests also verify the visual inspection and attestation requirements of the
          [§ 170.315(g)(31) certification
          criterion](https://healthit.gov/test-method/provider-prior-authorization-api-coverage-requirements-discovery).
        DESCRIPTION

        test from: :g31_documentation_attestation_test
      end
    )
  end
end
