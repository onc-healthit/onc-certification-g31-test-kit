module ONCCertificationG31TestKit
  module G31Options
    CRD_V221 = '2.2.1'.freeze
    CRD_V221_COMPACT = "v#{CRD_V221.delete('.')}".freeze              # v221
    CRD_V221_DOTTED = "v#{CRD_V221}".freeze                           # v2.2.1
    CRD_V221_PREFIX = "/crd_#{CRD_V221_COMPACT}".freeze               # /crd_v221
    CRD_V221_IG_PACKAGE = "hl7.fhir.us.davinci-crd##{CRD_V221}".freeze

    US_CORE_3 = 'us_core_3'.freeze
    US_CORE_4 = 'us_core_4'.freeze
    US_CORE_5 = 'us_core_5'.freeze
    US_CORE_6 = 'us_core_6'.freeze
    US_CORE_7 = 'us_core_7'.freeze

    US_CORE_VERSION_NUMBERS = {
      US_CORE_3 => '3.1.1',
      US_CORE_4 => '4.0.0',
      US_CORE_5 => '5.0.1',
      US_CORE_6 => '6.1.0',
      US_CORE_7 => '7.0.0'
    }.freeze

    US_CORE_3_REQUIREMENT = { us_core_version: US_CORE_3 }.freeze
    US_CORE_4_REQUIREMENT = { us_core_version: US_CORE_4 }.freeze
    US_CORE_5_REQUIREMENT = { us_core_version: US_CORE_5 }.freeze
    US_CORE_6_REQUIREMENT = { us_core_version: US_CORE_6 }.freeze
    US_CORE_7_REQUIREMENT = { us_core_version: US_CORE_7 }.freeze

    def us_core_version
      suite_options[:us_core_version]
    end
  end
end
