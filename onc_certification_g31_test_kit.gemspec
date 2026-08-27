require_relative 'lib/onc_certification_g31_test_kit/version'

Gem::Specification.new do |spec|
  spec.name          = 'onc_certification_g31_test_kit'
  spec.version       = ONCCertificationG31TestKit::VERSION
  spec.authors       = ['Inferno Team']
  # spec.email         = ['TODO']
  spec.summary       = 'ONC Certification (g)(31) Test Kit'
  spec.description   = 'ONC Certification (g)(31) Standardized API Test Kit'
  spec.homepage      = 'https://github.com/drajer-health/onc-certification-g31-test-kit'
  spec.license       = 'Apache-2.0'
  spec.add_dependency 'davinci_crd_test_kit', '~> 0.14', '>= 0.14.1'
  spec.add_dependency 'inferno_core', '~> 1.4', '>= 1.4.3'
  spec.add_dependency 'us_core_test_kit', '~> 1.0'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.3.6')
  spec.metadata['inferno_test_kit'] = 'true'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.files         = `[ -d .git ] && git ls-files -z lib config/presets execution_scripts LICENSE`.split("\x0")

  spec.require_paths = ['lib']
end
