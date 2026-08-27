This walkthrough introduces the **Inferno ONC Certification (g)(31) Standardized API Test Kit** by
demonstrating its use as an automated testing tool for the [§ 170.315(g)(31) Coverage Requirements
Discovery criterion](https://healthit.gov/test-method/provider-prior-authorization-api-coverage-requirements-discovery)
of the ONC Health IT Certification Program.

This test kit evaluates a **Health IT Module**. Inferno acts as
a CRD server and publishes simulated CDS services, waits for the Health IT Module to invoke them,
and then validates the requests it received and the way the Health IT Module handled Inferno's
responses. Because Inferno is waiting to be called, most scenarios pause on a 'User Action Required'
dialog until the Health IT Module has sent requests and the tester acknowledges that no more will
be sent.

At the end of this walkthrough, you will be able to use the test kit to evaluate a Health IT Module for
conformance to the (g)(31) certification criterion.

*   [Step 1: Create a new (g)(31) Test Session](#step-1-create-a-new-g31-test-session-and-select-the-us-core-version)
*   [Step 2: Configure the Health IT Module Under Test](#step-2-configure-the-health-it-module-under-test)
*   [Step 3: Perform Registration Tests](#step-3-perform-registration-tests)
*   [Step 4: Perform order-sign Hook Tests](#step-4-perform-order-sign-hook-tests)
*   [Step 5: Perform Cross Hook Tests](#step-5-perform-cross-hook-tests)
*   [Step 6: Perform Long-running Hook Request Tests](#step-6-perform-long-running-hook-request-tests)
*   [Step 7: Perform FHIR API Tests](#step-7-perform-fhir-api-tests)
*   [Step 8: Complete Visual Inspection and Attestation](#step-8-complete-visual-inspection-and-attestation)
*   [Step 9: Review Results](#step-9-review-results)

## Step 1: Create a new (g)(31) test session and select the US Core version

*   Start the test kit and navigate to it in a browser. When running locally following the
    [Getting Started](https://github.com/onc-healthit/onc-certification-g31-test-kit/?tab=readme-ov-file#getting-started)
    instructions, this will be <http://localhost:4567>.
*   Select 'ONC Certification (g)(31) Standardized API'.
*   Select which version of US Core to test against. The tests will only evaluate a Health IT Module
    against a single US Core version in a single session, so choose the version that matches the
    Health IT Module under test.

This creates a new test session. The header states which version of the test kit is being used and
which US Core version was selected.

The tests are organized into three scenarios that in sum cover the requirements of the criterion:

1.  **Hook Invocation** - the Health IT Module discovers Inferno's simulated CDS services and
    invokes them.
2.  **FHIR API** - the Health IT Module's own FHIR API is queried to confirm it exposes the US Core
    data that CRD services rely on.
3.  **Visual Inspection and Attestation** - requirements that are currently not verified through
    automated testing.

The scenarios are intended to be run in order. Later scenarios depend on data collected during
earlier ones; in particular, the FHIR API tests use the FHIR server URL and access token observed
in the hook requests.

## Step 2: Configure the Health IT Module under test

Inferno simulates **two** CRD servers, and both are used during testing. One requests the complete
[standard prefetch data set](https://hl7.org/fhir/us/davinci-crd/2.2.1/en/foundation.html#standard-prefetch)
and the other [requests only a subset](https://hl7.org/fhir/us/davinci-crd/2.2.1/en/foundation.html#ci-c-found-25),
which is how the tests confirm that
the Health IT Module can handle both. Configure the Health IT Module to use both CDS Hooks
discovery endpoints. This walkthrough assumes the test kit is deployed on `inferno.healthit.gov`;
replace the host below with the base URL of your Inferno instance if it is deployed elsewhere:

*   Complete prefetch: `https://inferno.healthit.gov/custom/g31_certification/crd_v221/cds-services`
*   Subset prefetch: `https://inferno.healthit.gov/custom/g31_certification/crd_v221/prefetch-subset/cds-services`

Fetching either endpoint returns the CDS Hooks discovery response listing the services Inferno
offers, including `order-sign-service`.

> **Demonstrating without a Health IT Module.** The
> [Burden Reduction provider reference implementation](https://br-provider.davinci.hl7.org/) can be
> connected to these endpoints and used to follow this walkthrough end to end. It will not pass
> every test, which is expected, but it lets the steps below describe a concrete example of how to
> trigger the corresponding hook invocations.

## Step 3: Perform Registration tests

The 'Registration' group records the connection details that the rest of the Hook Invocation tests
rely on, so run it first. No hook requests are exchanged during this group.

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

## Step 4: Perform order-sign Hook tests

The (g)(31) criterion requires support for the `order-sign` hook. This group verifies that the
Health IT Module invokes it correctly and handles Inferno's response.

*   Select '1.2.1 order-sign' and click 'RUN TESTS'.
*   Choose how Inferno should build its responses. See
    [Controlling Simulated Responses](https://github.com/inferno-framework/davinci-crd-test-kit/wiki/Controlling-Simulated-Responses)
    in the CRD Test Kit wiki for the full detail on how each approach works:
    *   **Response generation approach**: 'Create simple mocks based on selected response types'
        is the default and builds simple, generic cards and system actions from the response types
        selected below. Choosing 'Generate responses based on a tester-provided template' lets you
        supply your own response in the **Custom response template** field instead, which is
        necessary to demonstrate behavior that Inferno's mocked responses do not cover.
    *   **Response types to return**: locked to **Coverage Information**, which is the response type
        the (g)(31) criterion certifies for this hook.
*   Click 'SUBMIT'.

*   A 'User Action Required' dialog appears while Inferno waits for the Health IT Module to invoke
    the `order-sign` service. Trigger the workflow in the Health IT Module that signs an order.
*   When the Health IT Module has sent its requests, click the link in the dialog to continue.
*   A second 'User Action Required' dialog asks you to attest that the Health IT Module displayed
    the decision support details Inferno returned. Answer based on what you observed in the Health
    IT Module.

The group is organized into four sub-groups, which run in this order:

*   **1.2.1.1 Interaction** - confirms Inferno received `order-sign` hook requests.
*   **1.2.1.2 Authorization** - decodes the bearer token, retrieves the JWKS, and validates the
    token header and payload against the registration values from Step 3.
*   **1.2.1.3 Requests** - validates the structure and content of each request, the CRD version
    extension, prefetched resources against the required CRD profiles, prefetch completeness,
    granted scopes, and use of TLS.
*   **1.2.1.4 Response Handling** - validates the responses Inferno returned and confirms the
    Health IT Module supports the Coverage Information response type.

The Coverage Information support test in 1.2.1.4, and the equivalent test in Step 5's Cross Hook
group, require Inferno to have returned a Coverage Information response the Health IT Module can
recognize. Inferno's mocked responses do not provide full Coverage Information coverage, so
demonstrating support for this response type requires supplying a custom response template that
includes it.

Inferno provides in-depth information to help debug failures. Expand an individual test and open
the 'ABOUT' tab to read what it verifies, or open the 'Messages' and 'Requests' tabs to see the
validation output and the exact HTTP traffic Inferno received.

## Step 5: Perform Cross Hook tests

These tests examine the hook requests already captured in Step 4 rather than asking for new ones, so
run them after the order-sign group. They verify behavior that applies across hook invocations:
support for the Coverage Information response type, address propagation to child Location resources,
correct interpretation of collections in prefetch templates, unique `hookInstance` values, and the
ability to provide both the complete and the subset prefetch data sets.

*   Select '1.3 Cross Hook' and click 'RUN TESTS'. This group requires no inputs.

Note that the prefetch complete-and-subset test requires the Health IT Module to have invoked
**both** of the discovery endpoints described in Step 2.

## Step 6: Perform Long-running Hook Request tests

This group verifies that the user's workflow in the Health IT Module can continue while a CRD
service takes a long time to respond.

*   Select '1.4 Long-running Hook Request' and click 'RUN TESTS'.
*   Set **Long running pause time** to the number of seconds Inferno should wait before responding.
*   Click 'SUBMIT', then invoke any hook from the Health IT Module.
*   Attest whether the user was able to continue working while the request was outstanding.

## Step 7: Perform FHIR API tests

CRD services retrieve additional patient data from the Health IT Module's FHIR API. This scenario
runs the US Core tests for the version selected in Step 1 against that API.

*   Select '2 FHIR API' and click 'RUN TESTS'.
*   The **FHIR Server Base URL** is pre-populated from the hook requests captured earlier and is
    locked, which is why the Hook Invocation tests must be run first.
*   Provide the remaining inputs:
    *   **Auth info**: credentials for accessing the Health IT Module's FHIR API. This must be
        provided; a Health IT Module that allows Inferno to retrieve patient data without
        authorization is not securely configured, so the FHIR API tests are not a valid
        demonstration without it. See
        [FHIR API Testing](https://github.com/inferno-framework/davinci-crd-test-kit/wiki/Client-Instructions-v2.2.1#fhir-api-testing)
        in the CRD Test Kit wiki for additional detail.
    *   **Patient IDs**: one or more patient records that together include at least one example of
        every element labelled 'MUST SUPPORT' in the relevant US Core profiles.
    *   **Implantable device codes**: optional filter for Device resources.
*   Click 'SUBMIT'.

These tests follow the standard US Core pattern: search for each resource type associated with the
patient, run the required search combinations, validate returned resources against the relevant
profile, and confirm that references resolve. If the selected patients do not include all required
resources, some tests will be marked 'SKIP'; supply additional patient IDs and re-run to cover them.

## Step 8: Complete Visual Inspection and Attestation

Not every requirement can be verified automatically. This scenario collects attestations for the
remaining requirements of the criterion.

*   Select '3 Visual Inspection and Attestation'.
*   Each test asks you to confirm that the Health IT Module meets one or more **SHALL** requirements
    by selecting 'Yes' or 'No' in the input with the same name as the test before starting the run.
    Testers are responsible for confirming that the Health IT Module meets all requirements
    associated with a test before selecting "Yes" on the attestation input with the same name as
    the test. Selecting 'No' fails the test.
*   You may use the accompanying notes field to record supporting details.
    Notes are recorded in the test result.
*   To review the exact requirement text behind a test, open its 'ABOUT' tab and follow the
    'View Specification Requirements' link.

These tests cover areas such as security and privacy, response case distinction, data element
expectations, resource identifiers, must support handling, workflow integration, coverage-based
invocation, prefetch key omission, hook invocation logging, order-sign support, authorized scope,
and documentation.

## Step 9: Review Results

All tests have now been completed. To print out a copy of the results, click the 'Report' icon in
the menu on the left and then the 'Print' icon within that view. Export this report if you would
like to keep a copy of the results.