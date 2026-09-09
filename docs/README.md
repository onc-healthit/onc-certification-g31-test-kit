The **ONC Certification (g)(31) Coverage Requirements Discovery API Test Kit** is a testing tool
for Health IT systems seeking to meet the requirements of the ONC [Coverage
Requirements Discovery criterion §
170.315(g)(31)](https://healthit.gov/test-method/provider-prior-authorization-api-coverage-requirements-discovery)
in the ONC Health IT Certification Program. The following documentation provides information
on how to use and contribute to this test kit.

DISCLAIMER: this test kit is currently a draft and not ready for ONC certification purposes.

## Overview

This test kit validates conformance to the following implementation specifications required by the (g)(31) certification criterion:

*   Health Level 7 (HL7®) Fast Healthcare Interoperability Resources (FHIR®) (v4.0.1)
*   Da Vinci Coverage Requirements Discovery (CRD) Implementation Guide (v2.2.1)
*   CDS Hooks (v3.0.0-ballot) and the CDS Hooks Library (v1.0.1)
*   US Core Implementation Guide (v3.1.1, v6.1.0, or v7.0.0)

## Using this Test Kit

*   [Getting Started](https://github.com/onc-healthit/onc-certification-g31-test-kit#getting-started): Installation instructions for setting up and running this test kit locally.
*   [Test Kit Walkthrough](https://github.com/onc-healthit/onc-certification-g31-test-kit/wiki/Walkthrough): A step-by-step guide to using this test kit, including screenshots and detailed instructions for each testing scenario.

## Contributing to this Test Kit

Developers contributing to this test kit should be familiar with [authoring
Inferno Framework test suites](https://inferno-framework.github.io/docs/writing-tests/). These tests are largely a subset of the [CRD Test Kit](https://github.com/inferno-framework/davinci-crd-test-kit).
The following guides provide additional information about the design
and implementation of this test kit to aid in contributing to these tests:

*   [Technical Overview](Technical-Overview)
*   [Da Vinci CRD Test Kit Wiki](https://github.com/inferno-framework/davinci-crd-test-kit/wiki): Documentation for the CRD client tests that this test kit imports, including how Inferno simulates a CRD server and how its responses can be controlled.
*   [Controlling Simulated Responses](https://github.com/inferno-framework/davinci-crd-test-kit/wiki/Controlling-Simulated-Responses): How Inferno builds the CDS Hooks responses returned to the client under test, and how those responses can be customized.

## Support

For questions or issues with this test kit, please reach out to the Inferno team
on the [#Inferno FHIR Zulip
channel](https://chat.fhir.org/#narrow/stream/179309-inferno).

Report bugs or provide suggestions in [GitHub Issues](https://github.com/onc-healthit/onc-certification-g31-test-kit/issues).