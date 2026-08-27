# The CRD endpoint classes infer which IG version to apply from the suite id in the request path,
# which only resolves for the CRD client suites. These specs pin the version each g31 endpoint
# serves, so that bumping one of the version strings without the others fails here rather than
# silently serving the wrong IG.
RSpec.describe ONCCertificationG31TestKit::G31CDSServicesDiscoveryHandler do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('g31_certification') }
  let(:crd_handler) { DaVinciCRDTestKit::CDSServicesDiscoveryHandler }
  let(:discovery_handler) { described_class }
  let(:hook_endpoint) { ONCCertificationG31TestKit::G31HookRequestEndpoint }

  let(:version_prefix) { ONCCertificationG31TestKit::G31Options::CRD_V221_PREFIX }
  let(:discovery_path) { "/custom/#{suite.id}#{version_prefix}/cds-services" }
  let(:prefetch_subset_path) { "/custom/#{suite.id}#{version_prefix}/prefetch-subset/cds-services" }

  def discovery_body(path)
    discovery_handler.call({ 'PATH_INFO' => path })[2].first
  end

  describe 'the discovery endpoint' do
    it 'serves the CRD v2.2.1 service definitions' do
      expect(discovery_body(discovery_path)).to eq(crd_handler.cds_services('v2.2.1'))
    end

    it 'does not fall back to the CRD v2.0.1 service definitions' do
      expect(discovery_body(discovery_path)).to_not eq(crd_handler.cds_services('v2.0.1'))
    end

    it 'serves the v2.2.1 prefetch subset definitions on the subset path' do
      expect(discovery_body(prefetch_subset_path))
        .to eq(crd_handler.cds_services('v2.2.1', prefetch_subset: true))
    end

    it 'responds as json with CORS allowed' do
      status, headers, = discovery_handler.call({ 'PATH_INFO' => discovery_path })

      expect(status).to eq(200)
      expect(headers['Content-Type']).to eq('application/json')
      expect(headers['Access-Control-Allow-Origin']).to eq('*')
    end
  end

  describe 'the hook request endpoint' do
    it 'applies the CRD v2.2.1 branch of the hook request handling' do
      expect(hook_endpoint.allocate.ig_version).to eq('v221')
    end
  end

  describe 'suite routes' do
    let(:routes) { Inferno.routes.select { |route| route[:suite]&.id == suite.id } }

    it 'serves the discovery endpoints with the g31 handler' do
      discovery_routes = routes.select { |route| route[:method] == :get && route[:path].end_with?('/cds-services') }

      expect(discovery_routes.length).to eq(2)
      expect(discovery_routes.map { |route| route[:handler] }.uniq).to eq([discovery_handler])
    end

    it 'serves every CRD hook endpoint with the g31 endpoint' do
      hook_routes = routes.select { |route| route[:method] == :post }

      expect(hook_routes.length).to eq(12)
      expect(hook_routes.map { |route| route[:handler] }.uniq).to eq([hook_endpoint])
    end

    it 'allows CORS preflight on the hook and discovery paths' do
      expect(routes.count { |route| route[:method] == :options }).to eq(14)
    end

    it 'registers the resume routes the attestation tests link to, under the version prefix' do
      resume_paths = routes.select { |route| route[:method] == :get }.map { |route| route[:path] }

      expect(resume_paths).to include("#{version_prefix}/resume_pass", "#{version_prefix}/resume_fail")
    end
  end
end
