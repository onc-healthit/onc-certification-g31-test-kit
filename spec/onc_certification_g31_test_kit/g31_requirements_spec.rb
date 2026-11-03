RSpec.describe ONCCertificationG31TestKit::G31Requirements do
  let(:requirement_map) { described_class::REQUIREMENT_MAP }

  # Stands in for a runnable, following the DSL's verifies_requirements convention of setting the
  # requirements when given ids and returning them otherwise.
  let(:fake_runnable_class) do
    Class.new do
      attr_reader :id

      def initialize(id, requirements = [])
        @id = id
        @requirements = requirements
      end

      def verifies_requirements(*requirement_ids)
        @requirements = requirement_ids unless requirement_ids.empty?
        @requirements
      end
    end
  end

  # A suite whose descendants carry exactly one runnable per mapping key, plus any extras.
  def fake_suite(extra_descendants = [], skip_keys: [])
    keys = requirement_map.values.flatten.uniq - skip_keys
    descendants = keys.map { |key| fake_runnable_class.new("g31_certification-#{key}", ['existing@1']) }
    suite = fake_runnable_class.new('g31_certification')
    all_descendants = descendants + extra_descendants
    suite.define_singleton_method(:all_descendants) { all_descendants }
    suite
  end

  def find_descendant(suite, key)
    suite.all_descendants.find { |runnable| runnable.id == "g31_certification-#{key}" }
  end

  describe '.apply!' do
    it 'adds each requirement to every runnable mapped to it' do
      suite = fake_suite
      described_class.apply!(suite)

      requirement_map.each do |requirement_id, keys|
        keys.each do |key|
          expect(find_descendant(suite, key).verifies_requirements).to include(requirement_id)
        end
      end
    end

    it 'keeps the requirements a runnable already declares' do
      suite = fake_suite
      described_class.apply!(suite)

      expect(suite.all_descendants.map(&:verifies_requirements)).to all(include('existing@1'))
    end

    it 'does not duplicate requirements when applied more than once' do
      suite = fake_suite
      2.times { described_class.apply!(suite) }

      suite.all_descendants.each do |runnable|
        expect(runnable.verifies_requirements).to eq(runnable.verifies_requirements.uniq)
      end
    end

    it 'matches keys only against whole id segments' do
      lookalike = fake_runnable_class.new('g31_certification-not_crd_v221_client_registration')
      suite = fake_suite([lookalike], skip_keys: ['crd_v221_client_registration'])

      expect { described_class.apply!(suite) }
        .to raise_error(/No runnable found for requirement mapping key 'crd_v221_client_registration'/)
    end

    it 'raises when a key matches no runnable' do
      suite = fake_suite(skip_keys: ['g31_hook_invocation'])

      expect { described_class.apply!(suite) }
        .to raise_error(/No runnable found for requirement mapping key 'g31_hook_invocation'/)
    end

    it 'raises when a key matches more than one runnable' do
      duplicate = fake_runnable_class.new('g31_certification-other_group-g31_hook_invocation')
      suite = fake_suite([duplicate])

      expect { described_class.apply!(suite) }
        .to raise_error(/'g31_hook_invocation' matches multiple runnables/)
    end
  end

  describe 'when applied to the certification suite' do
    let(:suite) { Inferno::Repositories::TestSuites.new.find('g31_certification') }
    let(:runnables) { [suite, *suite.all_descendants] }

    def runnable_for(key)
      runnables.find { |runnable| runnable.id.to_s.end_with?("-#{key}") }
    end

    it 'attaches every mapped requirement to the runnable that verifies it' do
      requirement_map.each do |requirement_id, keys|
        keys.each do |key|
          expect(runnable_for(key).verifies_requirements).to include(requirement_id), "#{key} lacks #{requirement_id}"
        end
      end
    end

    it 'attaches the (g)(31) and (j)(20) requirements only where the map says to' do
      mapped = requirement_map.flat_map do |requirement_id, keys|
        keys.map { |key| [runnable_for(key).id, requirement_id] }
      end

      # The suite declares the requirements met by the kit as a whole, and the documentation
      # attestation declares its own, so those are left out of the comparison.
      regulatory = suite.all_descendants.flat_map do |runnable|
        runnable.verifies_requirements
          .select { |id| id.start_with?(described_class::G31_SET, described_class::J20_SET) }
          .map { |requirement_id| [runnable.id, requirement_id] }
      end
      regulatory.reject! { |_id, requirement_id| requirement_id == "#{described_class::G31_SET}@7" }

      expect(regulatory).to match_array(mapped)
    end
  end
end
