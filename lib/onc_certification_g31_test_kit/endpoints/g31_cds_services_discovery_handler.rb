require 'davinci_crd_test_kit/client/endpoints/cds_services_discovery_handler'
require_relative '../g31_options'

module ONCCertificationG31TestKit
  class G31CDSServicesDiscoveryHandler < DaVinciCRDTestKit::CDSServicesDiscoveryHandler
    def call(env)
      prefetch_subset = env['PATH_INFO'].split('/').include?('prefetch-subset')

      [
        200,
        { 'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => '*' },
        [self.class.cds_services(G31Options::CRD_V221_DOTTED, prefetch_subset:)]
      ]
    end
  end
end
