This walkthrough introduces the **Inferno ONC Certification (g)(31)
Coverage Requirements Discovery API Test Kit** by
demonstrating its use as an automated testing tool for the
[§ 170.315(g)(31) Coverage Requirements Discovery criterion](https://healthit.gov/test-method/provider-prior-authorization-api-coverage-requirements-discovery)
of the ONC Health IT Certification Program. At the end of this walkthrough,
you will be able to use the test kit to evaluate a Health IT Module for
conformance to the (g)(31) certification criterion.

## Understanding the (g)(31) Tests

This test kit evaluates a **Health IT Module**, specifically a provider system
in which orders can be signed. In these tests, the Health IT Module acts
as a client, making requests to Inferno's simulated server and reacting
to the responses Inferno sends back. [This client testing paradigm](https://inferno-framework.github.io/docs/getting-started/paradigms#client-initiator-testing)
requires a different approach to interactions than the server testing paradigm
used in test kits like Inferno's
[ONC Certification (g)(10) Standardized API Test Kit](https://github.com/onc-healthit/onc-certification-g10-test-kit/wiki/Walkthrough).
The following sections provide context for understanding how to use and
pass these tests.

### (g)(31) Client Testing Basics

To understand the basics of client testing for the (g)(31) tests, see the CRD Test Kit
wiki which has details on how the [client testing paradigm](https://github.com/inferno-framework/davinci-crd-test-kit/wiki/Client-Details#client-testing-paradigm)
applies to the CRD tests that are re-used by these (g)(31) tests.

### Tester-provided Responses in (g)(31)

In order to pass the (g)(31) tests, testers will need to provide responses
for Inferno to use that demonstrate the full scope of must support sub-extensions
within the [Coverage-Information](https://hl7.org/fhir/us/davinci-crd/2.2.1/en/StructureDefinition-ext-coverage-information.html)
extension. See the CRD Test Kit wiki for [details on why Inferno requires testers
to provide these responses](https://github.com/inferno-framework/davinci-crd-test-kit/wiki/Client-Details#tester-provided-responses)
and [how to specify them](https://github.com/inferno-framework/davinci-crd-test-kit/wiki/Controlling-Simulated-Responses#tester-directed-custom-responses).
If you have suggestions for how Inferno can better support testers in passing
these CRD must support requirements, you can submit them via [GitHub issues](https://github.com/onc-healthit/onc-certification-g31-test-kit/issues).

## Execution Walkthrough

The following steps necessary to complete certification testing are described in more detail below:
*   [Step 1: (g)(31) Test Session Creation](#step-1-g31-test-session-creation)
*   [Step 2: Registration](#step-2-registration)
*   [Step 3: `order-sign` Hook Invocation](#step-3-order-sign-hook-invocation)
*   [Step 4: Scenarios](#step-4-scenarios)
*   [Step 5: Cross Invocation Requirements](#step-5-cross-invocation-requirements)
*   [Step 6: Client FHIR API](#step-6-client-fhir-api)
*   [Step 7: Visual Inspection and Attestation](#step-7-visual-inspection-and-attestation)
*   [Step 8: Results Review](#step-8-results-review)

Most steps of this walkthrough include
demonstration execution details using the [ONC-hosted Inferno instance](https://inferno.healthit.gov/suites/g31_certification)
to evaluate the behavior of the 
[publicly available Da Vinci burden reduction BR Provider reference implementation](https://br-provider.davinci.hl7.org/),
showing the kinds of actions that a tester would take within a Health IT Module
when running these tests against it.

NOTE: If multiple people are running the demonstration against the BR Provider
reference implementation at the same time using the [ONC-hosted Inferno instance](https://inferno.healthit.gov/suites/g31_certification),
unexpected results may occur. If you see strange behavior, pause execution and
try again later.

### Step 1: (g)(31) Test Session Creation

* Go to <https://inferno.healthit.gov>.
* Click the 'ONC (g)(31) CRD API Test Kit' button under 'ONC Health Certification
  Program'.
* Select which version of US Core to use when evaluating the FHIR server capabilities
  of the Health IT Module.
* Click the 'Create Test Session' button.

This creates a new test session. The header states which version of the test kit is being used and
which US Core version was selected.

The tests are organized into three top-level groups that in sum cover the requirements
of the criterion:

1.  **Hook Invocation** - the Health IT Module discovers Inferno's simulated CDS services and
    invokes them. This will require multiple hook requests showing the full scope of
    required capabilities, including specific scenarios and demonstration of must support
    elements.
2.  **FHIR API** - Inferno queries the Health IT Module's own FHIR server to confirm
    it exposes the US Core APIs that CRD services rely on.
3.  **Visual Inspection and Attestation** - the tester confirms the Health IT Module
    conforms to requirements that are currently not verified through automated testing.

These groups are intended to be run in order because later groups depend on data collected
during earlier ones. In particular, the FHIR API tests use the FHIR server URL and access
token observed in the hook requests. However, it is allowed to skip tests and to go back
and re-run previously-executed tests. Note, however, that some checks evaluate requests
made during other tests (e.g., the must support tests) and these only consider requests
made during the most recent execution of each test in scope. When re-running a test
consider which required features were demonstrated only in the previous run and
ensure that requests made in the new run still demonstrate those features.

### Step 2: Registration

The 'Registration' group records the connection details that the rest
of the Hook Invocation tests rely on and provides the information the tester needs to
connect the Health IT Module to Inferno. Thus, it must be run first.

Executing this group involves the following steps:
*   Select '1.1 Registration' and click 'RUN TESTS'.
*   Provide the registration inputs:
    *   **CRD JWT Issuer** (`iss`): the value the Health IT Module will place in the `iss` claim of
        the JWT it uses to authorize its hook requests. This is required.
    *   **CRD JWKS**: the Health IT Module's JWK Set, either as a URL or inline JSON. Inferno uses
        this to verify the signature on the Health IT Module's bearer tokens.
    *   **Complete Prefetch Service Organization id** and **Subset Prefetch Service Organization id**:
        Each Inferno CRD service endpoint must be associated with a payer configuration in
        the Health IT Module that will be referenced as a FHIR Organization in the coverage resources
        sent in CRD requests. Provide the ids for these Organizations to assist in Inferno's validation.
        Note that one or both can be skipped if not known. The tests can still be executed and hook
        requests exchanged with Inferno in subsequent tests, but the tests will not fully pass.
*   Click 'SUBMIT'.

These values are carried forward and locked in the later hook groups, so you only enter them once.

Once started, Inferno will display a "User Action Required" dialog providing information the
tester needs to configure the Health IT Module to connect to Inferno, including Inferno's Service Discovery Endpoints:
*   Complete prefetch: `https://inferno.healthit.gov/custom/g31_certification/crd_v221/cds-services`
*   Subset prefetch: `https://inferno.healthit.gov/custom/g31_certification/crd_v221/prefetch-subset/cds-services`

Fetching either endpoint returns the CDS Hooks discovery response listing the services Inferno
offers, including one for the `order-sign` hook. Inferno will not respond successfully to hook 
requests made to advertised services during this test. However, testers can verify connectivity
by making hook requests and checking the HTTP status of the error response: a 422 HTTP response
code indicates the connection was successful while a 500 HTTP response code indicates failure.
The returned OperationOutcome will contain additional details.

Once the tester has used this information to configure the Health IT Module to make hook requests
against Inferno's services and confirmed connectivity if desired, the tester will click the
appropriate attestation link in the "User Response Required" dialog to signal to Inferno that
registration has been completed.

#### Reference implementation registration example

To configure the Da Vinci BR Provider reference implementation to connect to Inferno:
1. Create a (g)(31) testing session as described in [Step 1](#step-1-g31-test-session-creation)
   using any version of US Core.
1. Apply the "Da Vinci BR Provider Reference Implementation" preset which will set the correct
   input values to register the Da Vinci BR Provider reference implementation with Inferno,
   including its JWT `iss` (`https://br-provider.davinci.hl7.org`).
1. Select '1.1 Registration', click 'RUN TESTS', and then click 'SUBMIT' in the input dialog.
1. Once the "User Action Required" dialog appears, open a separate tab and navigate
   to https://br-provider.davinci.hl7.org/ and login (no password needed) as a practitioner
   (any).
1. Configure the connection to Inferno's simulated CRD server by:
   1. Clicking the gear icon in the upper right to open the settings dialog.
   1. Select the "Payor" tab
   1. Use the "Server" dropdown to select the "Custom" option.
   1. In the "CDS Services URL" input, put `https://inferno.healthit.gov/custom/g31_certification/crd_v221/cds-services`.
   1. Click the "Bypass payor-handled check" box.
   1. Click the "Save" button and close the dialog to complete the setup.
1. Return to the Inferno test session and click the link to attest that Inferno has been
   registered. In this demonstration, the BR Provider reference implementation has only
   been configured to send hook requests to a single endpoint and an Organization id
   has not been provided for the payer associated with the subset endpoint, so the
   tests are expected to fail on test "**1.1.01** Health IT Module registers with Inferno".

No hook requests will have been made during these steps.

### Step 3: `order-sign` Hook Invocation

The (g)(31) criterion requires support for the `order-sign` hook. This group verifies that the
Health IT Module invokes it correctly and handles Inferno's response. Within the group
are four sub-groups each with a particular role, though all must be run together
*   **1.2.1.1 Interaction** - During these tests, Inferno will wait for the hook requests from the
    Health IT Module.
*   **1.2.1.2 Response Handling** - Validates the structure and content of Inferno's simulated responses,
    which must themselves be conformant and not include custom extensions. Testers also confirm
    that the Health IT Module displayed information related to the Coverage Information
    response type appropriately as Inferno cannot automatically verify that display behavior.
*   **1.2.1.3 Requests** - Validates the structure and content of each request.
*   **1.2.1.4 Authorization** - Verifies the signed jwt used to authenticate the hook request.

To run the group:

*   Select '1.2.1 order-sign' and click 'RUN TESTS'.
*   Choose how Inferno should build its responses using the **Response generation approach** input.
    See [Controlling Simulated Responses](https://github.com/inferno-framework/davinci-crd-test-kit/wiki/Controlling-Simulated-Responses)
    in the CRD Test Kit wiki for the full detail on how each approach works:
    *   *'Create simple mocks based on selected response types'*
        is the default and builds a simple, generic coverage-information system action indicating
        that each submitted order is approved.
    *   *'Generate responses based on a tester-provided template'* lets you
        supply your own response in the **Custom response template** input. This is necessary to
        set up scenarios tailored to the Health IT Module so that it can demonstrate all of the
        required behavior. For example, the mocked [`coverage-information`](https://hl7.org/fhir/us/davinci-crd/2.2.1/en/StructureDefinition-ext-coverage-information.html)
        extension does not include all of the sub-extensions that must be demonstrated.
*   Click 'SUBMIT'.
*   A 'User Action Required' dialog appears while Inferno waits for the Health IT Module to invoke
    the `order-sign` service. Trigger the workflow in the Health IT Module that signs an order.
    * NOTE: Inferno will only respond to a hook request when it is in this waiting state AND
      it receives a hook request where the jwt in the Authorization header has the value from
      the **CRD JWT Issuer** input in its `iss` payload field. If Inferno is not in a waiting
      state or the `iss` is missing or has a different value, the request will not return
      a successful response or be associated with the session for conformance analysis.
*   When the Health IT Module has sent its requests and received responses back from Inferno,
    click the link in the dialog to continue.
*   A second 'User Action Required' dialog will ask you to attest that the Health IT
    Module displayed the decision support details Inferno returned. Answer based on what
    you observed in the Health IT Module.

#### Reference implementation hook invocation example

1. In the tab with the BR Provider reference implementation open, select a patient (any)
   to open their chart.
1. Start an encounter by clicking the "Start Encounter" button in the far upper right of
   the chart window. This will trigger an `encounter-start` hook request which the (g)(31) test
   suite does not support.
1. Select an order (any) from the "Add Order" dropdown and click the "+ Add" button to the right
   of the dropdown. This will trigger an `order-select` hook request which the (g)(31) test
   suite does not support.
1. In Inferno, run group "1.2.1 order-sign" without any changes to the inputs so that
   the default mocked coverage-information response will be used. When the dialog appears
   indicating Inferno is ready to receive requests, return to the tab with the reference
   implementation.
1. Click the "Sign all Orders" button at the bottom of the chart frame (scroll down). On the
   next screen, click the "Confirm & Sign" button. This will trigger hook requests and
   within a few seconds, you should see order coverage information update along with 
   details on the hook request and response in the frame at the right.
1. In the Inferno tab, click the link in the dialog to continue the tests. A new dialog
   will appear asking the tester to confirm that the returned responses were displayed
   or otherwise made available to the user appropriately, including the coverage-information
   system action. Determining the right response is a judgment call, but return to
   the BR Provider tab and decide which choice to make based on what you see. At the
   time of this writing the details from the coverage-information system action (e.g.,
   "covered" indication) were displayed in the list of signed orders. Inferno will then
   take a few moments to analyze the interactions and check them for conformance.

All tests may not pass. You can review the details in the tests to as described to review any failures.

### Step 4: Scenarios

During this group, you will demonstrate the conformant behavior of the Health IT Module
in specific situations. In these tests, only very specific details of the request and responses
matter, so only those details are verified rather than the entire set of checks performed in the
previous tests. Because the details of the requests and their responses are not checked
in detail, requests made during these tests are not included in the cross-invocation analysis
performed in [step 5](#step-5-cross-invocation-requirements).

This group contains sub-groups testing the following scenarios:
- Long-running Hook Response: The Health IT Module will make a hook request and Inferno will
  delay the response. The Health IT Module will then demonstrate that the user is not blocked
  from taking other actions while waiting for the response.
- Unknown Response Content: The Health IT Module will make a hook request and Inferno will
  return a response with unexpected content. The Health IT Module will show that it
  still displays the expected information and does not fail due to the unexpected content.
- Self-Pay: The Health IT Module will place an order in a context in which the patient
  has asked to not use insurance but that would normally trigger a hook request. Inferno
  will check that it did not receive a hook request for this order.
- Multiple Payers: The Health IT Module will place an order in a context in which
  coverages associated with two different payers apply, each associated with one of Inferno's
  two CRD service endpoints. Inferno will verify that coverage information was requested
  from only one.
- User Access Level Scoping: The Health IT Module will place an order for the same service
  twice using two different users with different access levels each triggering a hook
  request. Inferno will check that it had access to a more limited set of data during
  the second hook request made by the user with access to less data.

The specific actions that testers need to take are described within the descriptions
of each group and the "User Action Required" dialogs encountered when running
each group.

#### Reference implementation scenario example

The Da Vinci Burden Reduction reference implementation does not have the capability to perform
all of these scenarios. One that it can perform is the Long-running Hook Request case.
To do so, use the following steps:

1. Select a patient (any) to open their chart.
1. Start an encounter by clicking the "Start Encounter" button in the far upper right of
   the chart window. This will trigger an `encounter-start` hook request which the (g)(31) test
   suite does not support.
1. Select an order (any) from the "Add Order" dropdown and click the "+ Add" button to the right
   of the dropdown. This will trigger an `order-select` hook request which the (g)(31) test
   suite does not support.
1. In Inferno, run group "1.3.1 Long-running Hook Request". When the dialog appears
   indicating Inferno is ready
   to receive requests, return to the tab with the reference implementation.
1. Click the "Sign all Orders" button at the bottom of the chart frame (scroll down). On the
   next screen, click the "Confirm & Sign" button. This will trigger a hook request and
   Inferno will pause for 15 seconds before responding. Attempt to click around within the UI
   to do something useful, e.g., place another order, without disrupting the display of the
   response.
1. After the details on the order has displayed, or twenty seconds has elapsed, return to the
   Inferno tab. A new "User Action Required" dialog should be present asking for confirmation
   that you could continue the workflow while waiting for the response. Choose the answer
   based on your experience.

### Step 5: Cross Invocation Requirements

These tests examine the hook requests made by the Health IT Module against Inferno to ensure that
behaviors required across all hook requests but not necessarily on each are demonstrated.
If you didn't demonstrate all of these behaviors during the previous `order-sign` tests,
you have the opportunity to perform additional invocations. Note that only requests sent
during the last execution of a given test are included in the analysis, so re-running the
`order-sign` group or this group will cause requests submitted during the previous run of that
group to fall out of scope on the next run of this group.

*   Select "1.4 Cross-Invocation Requirements" and click 'RUN TESTS'.
    *   Decide whether to send additional invocations:
        *   If you don't want to submit additional requests use the input to indicate that
            and click "Submit". Inferno will perform the evaluation on only the hook requests
            made during the `order-sign` group. NOTE: you can re-run this group if you decide
            you need to submit additional invocations based on the outcome of the tests.
        *   Otherwise, provide Inferno response details as in [step 3](#step-3-order-sign-hook-invocation)
            and run the tests. As in [step 3](#step-3-order-sign-hook-invocation),
            A "User Action Required" dialog will appear asking you to submit hook requests and once
            you acknowledge they have been made you will be asked to attest to their correct display
            in the Health IT Module and then Inferno will check them for conformance.
    *   Indicate if there are any FHIR resource types profiled by CRD that Inferno should
        not expect to observe within requests made by the Health IT Module by deselecting
        resource types from inputs "Order types supported by the Health IT Module" and "Supporting
        resource types populated by the Health IT Module". By deselecting a
        resource type, you attest that the related information is not captured or displayed
        to users within the Health IT Module.
*   Once any additional invocations have been made, Inferno will check them in aggregate against
    the cross-invocation requirements, including
    *   Must Support - Demonstrated coverage of must support elements, including:
        *   Within requests, all must support elements indicated in profiles included within
            those requests. For these elements there is an option to attest to non-support
            to elements not demonstrated, and
        *   Within responses, all must support sub-extensions defined on the [coverage-information extension](https://hl7.org/fhir/us/davinci-crd/2.2.1/en/StructureDefinition-ext-coverage-information.html).
    *   Additional Capabilities - Evidence of:
        *   Child location address propagation.
        *   Interpretation of FHIRPath Collections returned for tokens in prefetch templates
            as a comma-delimited list.
        *   Non-reuse of `hookInstance` values
        *   The demonstrated ability to fulfill both the complete standard prefetch data set and
            a subset depending on what the CRD Service requested in its hook service description.
            Passing requires that the Health IT Module to have submitted requests against both
            of Inferno's service discovery endpoints described in [step 2](#step-2-registration).
        *   Non-reuse of JWT `jti` values

See the descriptions and [linked requirements](https://inferno-framework.github.io/docs/user-interface.html#test-specific-requirements-display)
of each test for details on what Inferno looks for.

Once complete, the tests will report details on any failures using the mechanisms described
in step 4. Review these and, if necessary, re-run the tests after re-submitting hook
requests demonstrating the additional features. Remember that re-executing a test where
the Health IT Module previously submitted hook requests will cause requests made during the prior
execution to fall out of scope. Therefore, features only demonstrated during that execution will
need to be demonstrated again during the new test run.

#### Reference implementation cross-hook example

1. Run group "1.4 Cross-Invocation Requirements" without submitting additional requests.
2. Many of the requirements will fail due to incomplete coverage, including no requests made against
   the prefetch subset `order-sign` service.

### Step 6: Client FHIR API

CRD services retrieve additional patient data from the Health IT Module's FHIR API and require
that the Health IT Module supports the full US Core FHIR API. It is not practical to verify
the full scope of this API during a hook call, so this group executes the US Core server tests
for the US Core version selected when creating the Inferno session. It also verifies that
`coverage-information` extensions from Inferno's responses are actually persisted and made
available over the Health IT Module's FHIR API.

*   Select '2 FHIR API' and click 'RUN TESTS'. The following inputs are required to run the tests:
    *   **FHIR Server Base URL**: This input is populated from `fhirServer` field of the most recent
        hook request made against Inferno in this session. It cannot be changed as Inferno must verify
        the behavior of the CRD Client's FHIR server and not some other system. If a hook request
        has not previously been made, these tests cannot be run.
    *   **Auth info**: This input contains credentials for accessing the Health IT Module's FHIR API.
        This input is also populated from the latest hook request made against Inferno in this session
        using the `fhirAuthorization.access_token` field. This can be changed as the access token
        provided in the hook request is not required to be active outside of the hook invocation.
        Inferno needs a long-running access token to evaluate the US Core FHIR API, so if the access
        token from the hook request is short lived and cannot be configured to be longer-lived, you
        can manually provide a new access token, and client Id plus refresh token if needed to refresh
        the token if it expires. If you do so, you attest that the manually-provided token has the
        same scope and access as those sent in the hook requests.
    *   **Patient IDs**: one or more patient records that together include at least one example of
        every element labelled 'MUST SUPPORT' in the relevant US Core profiles.
    *   **Implantable device codes**: optional filter for Device resources.
*   Click 'SUBMIT'.

These tests follow the standard US Core [server testing pattern](https://inferno-framework.github.io/docs/getting-started/paradigms#server-responder-testing):
search for each resource type associated with the
patient, run the required search combinations, validate returned resources against the relevant
profile, and confirm that references resolve. If the selected patients do not include all required
resources, some tests will be marked 'SKIP'; supply additional patient IDs and re-run to cover them.
Note that these tests can take a significant amount of time to complete due to the volume of searches
performed.

#### Reference implementation FHIR API example

The Da Vinci Burden Reduction reference implementation has a limited set of FHIR data available, but
running the tests illustrates the basics of the group execution.

1. In Inferno, select group '2 FHIR API', click 'RUN TESTS' and provide the following inputs (others
  will already be present):
  - **Patient IDs**: use the id of the patient(s) found in the `patient` context of the hook
  requests sent to Inferno, e.g., `pat014`.
2. Run the tests and wait while they complete.
3. While most sub-groups will fail, note that many tests in groups like "Patient Test" do pass.

### Step 7: Visual Inspection and Attestation

Not every requirement can be verified automatically. This scenario collects attestations for the
remaining requirements of the criterion.

*   Select '3 Visual Inspection and Attestation'.
*   Each test asks you to confirm that the Health IT Module meets one or more **SHALL** requirements
    by selecting 'Yes' or 'No' in the input with the same name as the test before starting the run.
    You are responsible for confirming that the Health IT Module meets all requirements
    associated with a test before selecting "Yes" on the attestation input with the same name as
    the test. Selecting 'No' fails the test.
*   You may use the accompanying notes field to record supporting details.
    Notes are recorded in the test result.
*   To review the exact requirement text behind a test, open its 'ABOUT' tab and follow the
    'View Specification Requirements' link.

These tests cover areas that are very broad or otherwise difficult to demonstrate or mechanically
verify, such as security and privacy and hook invocation logging.

### Step 8: Results Review

All tests have now been completed. Individual tests will contain in-depth information to help debug failures. Click
on the name of an individual test to access these details on the following tabs when relevant:
- **Messages**: A list of specific errors and messages that provide detail on reason for the outcome.
- **Requests**: Details on the requests that Inferno is evaluating during this test.
- **Inputs** and **Outputs**: Lists of the inputs Inferno used to determine test behavior and
  any outputs that Inferno recorded for use in future tests.
- **About**: Describes the test and the checks it performs in more detail. Most tests provide a
  "View Specification Requirements" link that opens a dialog with details on the specific source
  specification requirements verified by the test.

To print out a copy of the results, click the 'Report' icon in
the menu on the left and then the 'Print' icon within that view. Export this report if you would
like to keep a copy of the results.