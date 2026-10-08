This walkthrough introduces the **Inferno ONC Certification (g)(31)
Coverage Requirements Discovery API Test Kit** by
demonstrating its use as an automated testing tool for the
[§ 170.315(g)(31) Coverage Requirements Discovery criterion](https://healthit.gov/test-method/provider-prior-authorization-api-coverage-requirements-discovery)
of the ONC Health IT Certification Program. At the end of this walkthrough,
you will be able to use the test kit to evaluate a Health IT Module for
conformance to the (g)(31) certification criterion.

This test kit evaluates a **Health IT Module**, specifically a provider system
in which orders can be placed and signed. Each step of this walkthrough includes
demonstration execution details using the [ONC-hosted Inferno instance](https://inferno.healthit.gov/suites/g31_certification)
to evaluate the behavior of the 
[publicly available Da Vinci burden reduction BR Provider reference implementation](https://br-provider.davinci.hl7.org/),
showing the kinds of actions that a tester would take within a Health IT Module
when running these tests against it.

During the tests, Inferno will act as a CRD server for the Health IT Module to
interact with. Inferno publishes simulated CDS service endpoints,
waits for the Health IT Module to invoke them, and then validates the requests
it received and the way the Health IT Module handled Inferno's responses.
Because Inferno is waiting to be called, most scenarios pause on a 'User Action Required'
dialog. Inferno will only respond to hook requests when one of these dialog is active.
Once it is active the tester takes actions within the Health IT Module that trigger
the relevant hook requests and acknowledges within the Inferno UI once all
requests have been sent so that Inferno knows to start evaluating them.

NOTE: If multiple people are running the demonstration against the BR Provider
reference implementation at the same time using the [ONC-hosted Inferno instance](https://inferno.healthit.gov/suites/g31_certification),
unexpected results may occur. If you see strange behavior, pause execution and
try again later.

The following steps necessary to complete certification testing are described in more detail below:
*   [Step 1: Create a new (g)(31) Test Session](#step-1-create-a-new-g31-test-session-and-select-the-us-core-version)
*   [Step 2: Configure the Health IT Module](#step-2-configure-the-health-it-module)
*   [Step 3: Perform Registration Tests](#step-3-perform-registration-tests)
*   [Step 4: Perform order-sign Hook Tests](#step-4-perform-order-sign-hook-tests)
*   [Step 5: Perform Scenario Tests](#step-5-perform-scenario-tests)
*   [Step 6: Perform Cross Hook Tests](#step-6-perform-cross-hook-tests)
*   [Step 7: Perform FHIR API Tests](#step-7-perform-fhir-api-tests)
*   [Step 8: Complete Visual Inspection and Attestation](#step-8-complete-visual-inspection-and-attestation)
*   [Step 9: Review Results](#step-9-review-results)

## Step 1: Create a new (g)(31) test session and select the US Core version

* Go to <https://inferno.healthit.gov>.
* Click the 'ONC (g)(31) CRD API Test Kit' button under 'ONC Health Certification
  Program'.
  the requirements of the (g)(31) criterion in the ONC Health IT Certification Program.
* Select which version of US Core to use when evaluating the FHIR server capabilities
  of the Health IT Module.

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

## Step 2: Configure the Health IT Module

Inferno simulates **two** CRD servers, and both are used during testing. One requests the complete
[standard prefetch data set](https://hl7.org/fhir/us/davinci-crd/2.2.1/en/foundation.html#standard-prefetch)
and the other [requests only a subset](https://hl7.org/fhir/us/davinci-crd/2.2.1/en/foundation.html#ci-c-found-25).
During this walkthrough, only the standard prefetch service will be used. However,
in order to pass the certification tests, Health IT Modules will need to demonstrate that they
can associate each of these Inferno CDS Service endpoints with a different payor (identified by a FHIR
Organization id) and invoke hooks against them, providing the requested prefetch data.

Inferno Service Discovery Endpoints:
*   Complete prefetch: `https://inferno.healthit.gov/custom/g31_certification/crd_v221/cds-services`
*   Subset prefetch: `https://inferno.healthit.gov/custom/g31_certification/crd_v221/prefetch-subset/cds-services`

Fetching either endpoint returns the CDS Hooks discovery response listing the services Inferno
offers, including one for the `order-sign` hook.

### Reference implementation configuration example

To configure the Da Vinci BR Provider reference implementation to connect to Inferno:
1. In a separate tab, navigate to https://br-provider.davinci.hl7.org/ and login (no password
   needed) as a practitioner (any).
1. Configure the connection to Inferno's simulated CRD server by:
   1. Clicking the gear icon in the upper right to open the settings dialog.
   1. Select the "Payor" tab
   1. Use the "Server" dropdown to select the "Custom" option.
   1. In the "CDS Services URL" input, put `https://inferno.healthit.gov/custom/g31_certification/crd_v221/cds-services`.
   1. Click the "Bypass payor-handled check" box.
   1. Click the "Save" button and close the dialog to complete the setup.

## Step 3: Perform Registration tests

The 'Registration' group records the connection details that the rest of the Hook Invocation tests
rely on, so it must be run first. No hook requests are exchanged during this group.

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
*   Click 'SUBMIT'.

These values are carried forward and locked in the later hook groups, so you only enter them once.

### Reference implementation registration example

The input values to register the BR Provider reference implementation can be pulled in
by applying the "Da Vinci BR Provider Reference Implementation" preset before
running the "Registration" group.

In this demonstration, the BR Provider reference implementation has only been configured
to send hook requests to a single endpoint and an Organization id has not been provided
for the payer associated with the subset endpoint, so the tests are expected to fail
on test "**1.1.01** Health IT Module registers with Inferno".

## Step 4: Perform order-sign Hook tests

The (g)(31) criterion requires support for the `order-sign` hook. This group verifies that the
Health IT Module invokes it correctly and handles Inferno's response.

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

The group is organized into four sub-groups:

*   **1.2.1.1 Interaction** - During these tests, Inferno will wait for the hook requests from the
    Health IT Module.
*   **1.2.1.2 Response Handling** - Validates the structure and content of Inferno's simulated responses,
    which must themselves be conformant and not include custom extensions. Testers also confirm
    that the Health IT Module displayed information related to the Coverage Information
    response type appropriately as Inferno cannot automatically verify that display behavior.
*   **1.2.1.3 Requests** - Validates the structure and content of each request.
*   **1.2.1.4 Authorization** - Verifies the signed jwt used to authenticate the hook request.


After execution is complete, each test contains in-depth information to help debug failures. Click
on the name of an individual test to access these details on the following tabs when relevant:
- **Messages**: A list of specific errors and messages that provide detail on reason for the outcome.
- **Requests**: Details on the requests that Inferno is evaluating during this test.
- **Inputs** and **Outputs**: Lists of the inputs Inferno used to determine test behavior and
  any outputs that Inferno recorded for use in future tests.
- **About**: Describes the test and the checks it performs in more detail. Also may provide a
  "View Specification Requirements" link that opens a dialog with details on the specific source
  specification requirements verified by the test.

### Reference implementation hook invocation example

1. Select a patient (any) to open their chart.
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

## Step 5: Perform scenario tests

During this group, you will demonstrate the conformant behavior of the Health IT Module
in specific situations. In these tests, only very specific details of the request and responses
matter, so only those details are verified rather than the entire set of checks performed in the
previous tests. Because the details of the requests and their responses are not checked
in detail, requests made during these tests are not included in the cross-hook analysis
performed later.

The following scenarios are included:
- Long-running Hook Response: The Health IT Module will make a hook request and Inferno will
  delay the response. The Health IT Module will then demonstrate that the user is not blocked
  from taking other actions while waiting for the response.
- Unknown Response Content: The Health IT Module will make a hook request and Inferno will
  return a response with unexpected content. The Health IT Module will show that it
  still displays the expected information and does not fail due to the unexpected content.
- Self-Pay: The Health IT Module will place an order in a context in which the patient
  has asked to not use insurance but that would normally trigger a hook request. Inferno
  will confirm that no hook request was sent for this order.
- Multiple Payers: The Health IT Module will make place an order in a context in which
  coverages associated with two different payers apply, each associated with one of Inferno's
  two CRD service endpoints. Inferno will verify that coverage information was requested
  from only one.
- User Access Level Scoping: The Health IT Module will place an order for the same service
  twice using two different users with different access levels each triggering a hook
  request. Inferno will check that it had access to a more limited set of data during
  the second hook request made by the user with access to less data.

The specific actions that testers need to take are described within the descriptions
of each group and the wait dialogs encountered when running the tests.

### Reference implementation scenario example

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
1. In Inferno, run group "1.3.1 Long-running Hook Request" changing the **Long-running
   Request Pause Time** input to `10`. When the dialog appears indicating Inferno is ready
   to receive requests, return to the tab with the reference implementation.
1. Click the "Sign all Orders" button at the bottom of the chart frame (scroll down). On the
   next screen, click the "Confirm & Sign" button. This will trigger a hook request and
   Inferno will pause for 10s before responding. Attempt to click around within the UI
   to do something useful, e.g., place another order, without disrupting the display of the
   response.
1. After the details on the order has displayed, or ten seconds has elapsed, return to the
   Inferno tab. A new "User Action Required" dialog should be present asking for confirmation
   that you could continue the workflow while waiting for the response. Choose the answer
   based on your experience.

## Step 6: Perform Cross Hook tests

These tests examine the hook requests made by the Health IT Module against Inferno to ensure that
behaviors required across all hook requests but not necessarily on each are demonstrated.
If testers didn't demonstrate all of these behaviors during the previous `order-sign` tests,
they have the opportunity to perform additional interactions. Note that only requests sent
during the last execution of a given test are included in the analysis, so re-running the
`order-sign` group or this group will cause requests submitted during the previous run of that
group to fall out of scope.

*   Select "1.4 Cross Hook" and click 'RUN TESTS'.
    *   If you don't want to submit additional requests use the input to indicate that
      and click "Submit". Inferno will perform the evaluation on only the hook requests
      made during the `order-sign` group.
    *   Otherwise, provide Inferno response details as in step 4 and run the tests. As in step 4,
        A "User Action Required" dialog will appear asking you to submit hook requests and once
        you acknowledge they have been made you will be asked to attest to their correct display
        in the Health IT Module and then Inferno will check them for conformance.
*   Once any additional tests have been made, Inferno will check them in aggregate against
    the cross-hook criteria, including
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
            of Inferno's service discovery endpoints described in [step 2](#step-2-configure-the-health-it-module).

See the descriptions and [linked requirements](https://inferno-framework.github.io/docs/user-interface.html#test-specific-requirements-display)
of each test for details on what Inferno looks for.

Once complete, the tests will report details on any failures using the mechanisms described
in step 4. Review these and, if necessary, re-run the tests after re-submitting hook
requests demonstrating the additional features. Remember that re-executing a test where
the Health IT Module submits hook requests will cause requests made during the prior
execution to fall out of scope, so features only demonstrated during that execution will
need to be demonstrated again during the new test run.

### Reference implementation cross-hook example

1. Run group "1.4 Cross Hook" without submitting additional requests.
2. Many of the requirements will fail due to incomplete coverage, including no requests made against
   the prefetch subset `order-sign` service.

## Step 7: Perform FHIR API tests

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

These tests follow the standard US Core pattern: search for each resource type associated with the
patient, run the required search combinations, validate returned resources against the relevant
profile, and confirm that references resolve. If the selected patients do not include all required
resources, some tests will be marked 'SKIP'; supply additional patient IDs and re-run to cover them.
Note that these tests can take a significant amount of time to complete due to the volume of searches
performed.

### Reference implementation FHIR API example

The Da Vinci Burden Reduction reference implementation has a limited set of FHIR data available, but
running the tests illustrates the basics of the group execution.

1. In Inferno, select group '2 FHIR API', click 'RUN TESTS' and provide the following inputs (others
  will already be present):
  - **Patient IDs**: use the id of the patient(s) found in the `patient` context of the hook
  requests sent to Inferno, e.g., `pat014`.
2. Run the tests and wait while they complete.
3. While most sub-groups will fail, note that many tests in groups like "Patient Test" do pass.

## Step 8: Complete Visual Inspection and Attestation

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

## Step 9: Review Results

All tests have now been completed. To print out a copy of the results, click the 'Report' icon in
the menu on the left and then the 'Print' icon within that view. Export this report if you would
like to keep a copy of the results.