require 'davinci_crd_test_kit/client/v2.2.1/client_urls'
require_relative 'g31_options'

module ONCCertificationG31TestKit
  module G31ClientURLs
    SUITE_ID = 'g31_certification'.freeze

    def inferno_base_url
      @inferno_base_url ||= G31CRDImport.base_url
    end
  end

  module G31CRDImport
    STALE_CACHE_IVARS = [:@test_count, :@available_inputs, :@children_available_inputs].freeze

    def self.import!(runnable)
      exclude_optional!(runnable)
      rewrite_crd_urls!(runnable)

      runnable
    end

    def self.exclude_optional!(runnable)
      runnable.all_children.reject(&:required?).each(&:remove_self_from_repository)
      runnable.all_children.select!(&:required?)
      STALE_CACHE_IVARS.each do |ivar|
        runnable.remove_instance_variable(ivar) if runnable.instance_variable_defined?(ivar)
      end

      runnable.all_children.each { |child| exclude_optional!(child) }
    end

    def self.rewrite_crd_urls!(runnable)
      runnable.include(G31ClientURLs) if runnable.include?(DaVinciCRDTestKit::V221::ClientURLs)
      rewrite_runnable_text!(runnable)
      rewrite_input_descriptions!(runnable)

      runnable.all_children.each { |child| rewrite_crd_urls!(child) }
    end

    def self.rewrite_runnable_text!(runnable)
      [:description, :input_instructions].each do |field|
        text = runnable.send(field).to_s
        next unless text.include?(crd_base_url)

        runnable.send(field, text.gsub(crd_base_url, base_url))
      end
    end
    private_class_method :rewrite_runnable_text!

    def self.rewrite_input_descriptions!(runnable)
      updates = runnable.config.inputs.each_with_object({}) do |(identifier, input), acc|
        description = input.description.to_s
        next unless description.include?(crd_base_url)

        acc[identifier] = { description: description.gsub(crd_base_url, base_url) }
      end

      runnable.config(inputs: updates) if updates.any?
    end
    private_class_method :rewrite_input_descriptions!

    # Includes the CRD version prefix, so imported tests point at this suite's v2.2.1 endpoints
    # rather than at the suite root.
    def self.base_url
      "#{Inferno::Application['base_url']}/custom/#{G31ClientURLs::SUITE_ID}#{G31Options::CRD_V221_PREFIX}"
    end

    def self.crd_base_url
      "#{Inferno::Application['base_url']}/custom/#{DaVinciCRDTestKit::V221::ClientURLs::SUITE_ID}"
    end
  end
end
