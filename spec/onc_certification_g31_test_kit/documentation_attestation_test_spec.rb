# @note includes RSpec shared context 'when testing a runnable'
RSpec.describe ONCCertificationG31TestKit::DocumentationAttestationTest do
  let(:suite_id) { 'g31_certification' }
  let(:test) { described_class }

  it 'is marked as an attestation' do
    expect(test.attestation?).to be(true)
  end

  it 'verifies the (g)(31) requirement 7 documentation requirement' do
    expect(test.verifies_requirements).to eq(['170.315(g)(31)_HTI-4@7'])
  end

  describe 'Health IT Module demonstrated that complete technical documentation accompanies its ' \
           'supported API server capabilities.' do
    it 'passes when the tester attests the documentation is complete' do
      result = run(test, g31_documentation_supported: 'true')

      expect(result.result).to eq('pass'), result.result_message
    end

    it 'fails when the tester attests the documentation is not complete' do
      result = run(test, g31_documentation_supported: 'false')

      expect(result.result).to eq('fail'), result.result_message
      expect(result.result_message).to include('did not demonstrate')
    end

    it 'skips when the tester does not answer the attestation' do
      result = run(test)

      expect(result.result).to eq('skip'), result.result_message
    end
  end
end
