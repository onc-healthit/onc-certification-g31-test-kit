module ONCCertificationG31TestKit
  ATTESTATION_INPUT_INSTRUCTIONS = %(
    Testers are responsible for confirming that their system meets all requirements associated with a test
    before selecting "Yes" on the attestation input with the same name as the test. The text of the
    attested requirement(s) for each input can be reviewed by clicking the "View Specification Requirements" link
    in the "About" tab of the test with the same name.
  ).freeze

  class DocumentationAttestationTest < Inferno::Test
    ATTESTATION_TITLE = 'Health IT module maintains complete technical documentation for its ' \
                        'supported API server capabilities.'.freeze
    title ATTESTATION_TITLE
    description %(
      During this test, the tester will confirm that complete technical documentation accompanies
      the Health IT Module's supported API server capabilities.
      To see the specifics of the attested requirements, click the "View Specification Requirements" link for this
      test.
    )
    id :g31_documentation_attestation_test
    attestation
    verifies_requirements '170.315(g)(31)_HTI-4@7'
    input_instructions ATTESTATION_INPUT_INSTRUCTIONS

    input :g31_documentation_supported,
          title: ATTESTATION_TITLE,
          description: %(
            I attest that complete technical documentation accompanies the Health IT Module's
            supported API server capabilities.
          ),
          type: 'radio',
          default: 'false',
          options: {
            list_options: [
              {
                label: 'Yes',
                value: 'true'
              },
              {
                label: 'No',
                value: 'false'
              }
            ]
          }
    input :g31_documentation_notes,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert g31_documentation_supported == 'true',
             'Health IT Module did not demonstrate that complete technical documentation accompanies its ' \
             'supported API server capabilities.'
    end
  end
end
