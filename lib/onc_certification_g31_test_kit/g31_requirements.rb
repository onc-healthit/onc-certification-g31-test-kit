module ONCCertificationG31TestKit
  # Maps the § 170.315(g)(31) and § 170.315(j)(20) certification requirements onto the runnables
  # imported from the Da Vinci PAS client suite.
  #
  # The imported runnables already declare the IG-level requirements that they verify, so these
  # regulatory requirements are added to what each one declares rather than replacing it.
  #
  # Regulatory requirements are written at the level of a whole capability, so they are attached to
  # the group that exercises that capability when no single test demonstrates it, and to individual
  # tests when one does.
  module G31Requirements
    G31_SET = '170.315(g)(31)_HTI-4'.freeze
    J20_SET = '170.315(j)(20)_HTI-4'.freeze

    # Requirement id => the runnables that verify it, identified by the trailing portion of their id
    # within this suite. Keys are the shortest suffix that identifies a single runnable; ids that
    # are reused across groups (e.g. the response attestation) are qualified by their parent.
    REQUIREMENT_MAP = {
      "#{G31_SET}@3" => [
        'crd_v221_client_registration'
      ],
      "#{G31_SET}@4" => [
        'g31_hook_invocation'
      ],
      "#{G31_SET}@5" => [
        'crd_v221_client_order_sign'
      ],
      "#{J20_SET}@1" => [
        'g31_hook_invocation'
      ],
      "#{J20_SET}@2" => [
        'crd_v221_client_registration'
      ],
      "#{J20_SET}@3" => [
        'crd_v221_order_sign_auth',
        'crd_v221_cross_hook_auth'
      ],
      "#{J20_SET}@4" => [
        'crd_v221_order_sign_auth',
        'crd_v221_cross_hook_auth'
      ],
      "#{J20_SET}@5" => [
        'crd_v221_order_sign_requests-crd_v221_hook_data_fetch_verification',
        'crd_v221_cross_hook_requests-crd_v221_hook_data_fetch_verification'
      ],
      "#{J20_SET}@6" => [
        'crd_v221_client_order_sign',
        'crd_v221_client_cross_hook_interaction'
      ],
      "#{J20_SET}@7" => [
        'crd_v221_client_order_sign',
        'crd_v221_client_cross_hook_interaction'
      ],
      "#{J20_SET}@8" => [
        'crd_v221_order_sign_requests-crd_v221_hook_data_fetch_verification',
        'crd_v221_cross_hook_requests-crd_v221_hook_data_fetch_verification'
      ],
      "#{J20_SET}@9" => [
        'crd_v221_order_sign_responses-crd_v221_card_display_attest_test',
        'crd_v221_cross_hook_responses-crd_v221_card_display_attest_test'
      ]
    }.freeze

    # Adds the requirements above to the runnables that verify them. Raises if a key no longer
    # identifies exactly one runnable, so that a change to the imported suite is caught here rather
    # than silently dropping coverage.
    def self.apply!(suite)
      runnables = [suite, *suite.all_descendants]

      REQUIREMENT_MAP.each do |requirement_id, runnable_keys|
        runnable_keys.each do |runnable_key|
          add_requirement!(find_runnable!(runnables, runnable_key), requirement_id)
        end
      end
    end

    def self.find_runnable!(runnables, runnable_key)
      matches = runnables.select { |runnable| runnable.id.to_s.end_with?("-#{runnable_key}") }

      raise "No runnable found for requirement mapping key '#{runnable_key}'" if matches.empty?

      if matches.length > 1
        raise "Requirement mapping key '#{runnable_key}' matches multiple runnables: " \
              "#{matches.map(&:id).join(', ')}"
      end

      matches.first
    end
    private_class_method :find_runnable!

    def self.add_requirement!(runnable, requirement_id)
      runnable.verifies_requirements(*(runnable.verifies_requirements + [requirement_id]).uniq)
    end
    private_class_method :add_requirement!
  end
end
