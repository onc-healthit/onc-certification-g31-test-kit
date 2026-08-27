require 'davinci_crd_test_kit/client/endpoints/hook_request_endpoint'
require_relative '../g31_options'

module ONCCertificationG31TestKit
  class G31HookRequestEndpoint < DaVinciCRDTestKit::HookRequestEndpoint
    def ig_version
      G31Options::CRD_V221_COMPACT
    end
  end
end
