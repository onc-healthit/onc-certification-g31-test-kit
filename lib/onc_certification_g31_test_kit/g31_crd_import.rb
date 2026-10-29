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
    RUNNABLE_TEXT_FIELDS = [:title, :short_title, :description, :input_instructions].freeze
    INPUT_TEXT_FIELDS = [:title, :description].freeze

    # Singular references only: statements about "CRD clients" in general are left as is.
    # NOTE: this pattern gets replaced within static text in the suite (descriptions,
    #       titles for runnables and inputs). It does not update the same strings within
    #       dynamic messages associated with the runnable during testing. This is expected
    #       and documented in docs/Technical-Overview.md.
    CRD_CLIENT_PATTERN = /CRD client(?!s)/
    HEALTH_IT_MODULE = 'Health IT Module'.freeze

    def self.import!(runnable)
      exclude_optional!(runnable)
      rewrite_crd_references!(runnable)

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
    private_class_method :exclude_optional!

    def self.rewrite_crd_references!(runnable)
      runnable.include(G31ClientURLs) if runnable.include?(DaVinciCRDTestKit::V221::ClientURLs)
      rewrite_runnable_text!(runnable)
      rewrite_input_text!(runnable)

      runnable.all_children.each { |child| rewrite_crd_references!(child) }
    end
    private_class_method :rewrite_crd_references!

    def self.rewrite_runnable_text!(runnable)
      RUNNABLE_TEXT_FIELDS.each do |field|
        text = runnable.send(field)
        next if text.nil?

        rewritten = rewrite_text(text)
        runnable.send(field, rewritten) unless rewritten == text
      end
    end
    private_class_method :rewrite_runnable_text!

    def self.rewrite_input_text!(runnable)
      updates = runnable.config.inputs.each_with_object({}) do |(identifier, input), acc|
        input_updates = INPUT_TEXT_FIELDS.each_with_object({}) do |field, field_acc|
          text = input.send(field)
          next if text.nil?

          rewritten = rewrite_text(text)
          field_acc[field] = rewritten unless rewritten == text
        end

        acc[identifier] = input_updates if input_updates.any?
      end

      runnable.config(inputs: updates) if updates.any?
    end
    private_class_method :rewrite_input_text!

    def self.rewrite_text(text)
      text.to_s.gsub(crd_base_url, base_url).gsub(CRD_CLIENT_PATTERN, HEALTH_IT_MODULE)
    end
    private_class_method :rewrite_text

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
