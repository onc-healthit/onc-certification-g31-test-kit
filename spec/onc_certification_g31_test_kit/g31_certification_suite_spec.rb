RSpec.describe ONCCertificationG31TestKit::G31CertificationSuite do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('g31_certification') }

  # Every runnable in the suite, depth first.
  def all_runnables(runnable = suite, collected = [])
    collected << runnable
    runnable.all_children.each { |child| all_runnables(child, collected) }
    collected
  end

  def imported_crd_tests
    all_runnables.select do |runnable|
      runnable < Inferno::Test && runnable.include?(DaVinciCRDTestKit::V221::ClientURLs)
    end
  end

  def us_core_option(value)
    [Inferno::DSL::SuiteOption.new(id: :us_core_version, value:)]
  end

  # The CRD IG version lives in a path prefix rather than in the suite id, so that a later version
  # can be added to this same suite as another prefixed set of endpoints.
  describe 'suite identity' do
    it 'uses a version neutral suite id' do
      expect(suite.id).to eq('g31_certification')
      expect(ONCCertificationG31TestKit::G31ClientURLs::SUITE_ID).to eq(suite.id)
    end

    it 'is the id the test kit registers' do
      expect(ONCCertificationG31TestKit::Metadata.suite_ids).to include(suite.id.to_sym)
    end

    it 'serves every CRD endpoint under a version prefix' do
      paths = Inferno.routes.select { |route| route[:suite]&.id == suite.id }.map { |route| route[:path] }

      expect(paths).to_not be_empty
      expect(paths).to all(start_with(ONCCertificationG31TestKit::G31Options::CRD_V221_PREFIX))
    end

    # The imported tests build their own urls, so they have to agree with where the endpoints are
    # actually registered.
    it 'builds test urls that match the prefix the endpoints are registered under' do
      expect(ONCCertificationG31TestKit::G31CRDImport.base_url).to eq(
        "#{Inferno::Application['base_url']}/custom/#{suite.id}" \
        "#{ONCCertificationG31TestKit::G31Options::CRD_V221_PREFIX}"
      )
    end
  end

  describe 'structure' do
    it 'imports order-sign as required rather than optional' do
      order_sign = all_runnables.find { |runnable| runnable.title == 'order-sign' }

      expect(order_sign).to_not be_nil
      expect(order_sign.optional?).to be(false)
    end

    it 'omits the hook groups other than order-sign' do
      titles = all_runnables.map(&:title)

      expect(titles).to_not include('appointment-book', 'encounter-start', 'encounter-discharge',
                                    'order-select', 'order-dispatch')
    end
  end

  describe 'optional exclusion' do
    it 'excludes every optional runnable, not just direct children of the imported groups' do
      optional = all_runnables.reject { |runnable| runnable == suite }.select(&:optional?)

      expect(optional.map(&:id)).to be_empty
    end
  end

  describe 'CRD url rewriting' do
    let(:crd_base_url) { ONCCertificationG31TestKit::G31CRDImport.crd_base_url }
    let(:base_url) { ONCCertificationG31TestKit::G31CRDImport.base_url }

    it 'resolves run time urls against this suite rather than the CRD client suite' do
      base_urls = imported_crd_tests.map { |test| test.new.inferno_base_url }.uniq

      expect(imported_crd_tests).to_not be_empty
      expect(base_urls).to eq([base_url])
    end

    it 'rewrites CRD urls baked into descriptions and input instructions' do
      stale = all_runnables.select do |runnable|
        [runnable.description, runnable.input_instructions].any? { |text| text.to_s.include?(crd_base_url) }
      end

      expect(stale.map(&:id)).to be_empty
    end

    it 'rewrites CRD urls baked into input descriptions' do
      stale = all_runnables.select do |runnable|
        runnable.config.inputs.each_value.any? { |input| input.description.to_s.include?(crd_base_url) }
      end

      expect(stale.map(&:id)).to be_empty
    end
  end

  describe 'US Core version suite option' do
    let(:option) { suite.suite_options.find { |suite_option| suite_option.id == :us_core_version } }
    let(:fhir_api_group) { suite.groups.find { |group| group.title == 'FHIR API' } }

    it 'offers the versions (g)(31) certifies against' do
      expect(option.list_options.map { |list_option| list_option[:value] }).to eq(
        [ONCCertificationG31TestKit::G31Options::US_CORE_3, ONCCertificationG31TestKit::G31Options::US_CORE_6,
         ONCCertificationG31TestKit::G31Options::US_CORE_7]
      )
    end

    it 'selects the matching US Core group for each version' do
      selected = ['us_core_3', 'us_core_6', 'us_core_7'].map do |value|
        fhir_api_group.children(us_core_option(value)).map { |group| group.id.split('-').last }
      end

      expect(selected).to eq([['us_core_v311_fhir_api'], ['us_core_v610_fhir_api'], ['us_core_v700_fhir_api']])
    end

    it 'reaches exactly one US Core group under each offered version' do
      ['us_core_3', 'us_core_6', 'us_core_7'].each do |value|
        selected = fhir_api_group.children(us_core_option(value))

        expect(selected.length).to eq(1), "#{value} selected #{selected.length} groups"
      end
    end
  end
end
