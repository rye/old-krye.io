require 'spec_helper'

describe 'lib/site/cache/redis_adapter.rb' do

	it 'can be required without error' do
		expect do
			require 'site/cache/redis_adapter'
		end.not_to raise_error
	end

end

require 'site/cache/redis_adapter'

describe Site::RedisAdapter do

	it 'is a Site::Adapter' do
		expect(Site::RedisAdapter).to be < Site::Adapter
	end

	describe '#replace_values' do
		before do Site::RedisAdapter.send(:public, *Site::RedisAdapter.protected_instance_methods) end
		subject do Site::RedisAdapter.allocate end
		let(:hash) { {:a => "a", :b => "b", :c => "c"} }

		context 'taking a hash' do
			it 'returns the hash without changing it' do
				expect(subject.replace_values(hash)).to eq(hash)
			end
		end

		context 'taking a hash with a filter that applies but no value' do
			let(:filtered_keys) { [:c] }

			it 'returns the hash without changing it' do
				expect(subject.replace_values(hash, filtered_keys)).to eq(hash)
			end
		end

		context 'taking a hash with a filter that does not apply' do
			let(:filtered_keys) { [:d] }
			let(:value) { "[___FILTERED___]" }

			it 'returns the hash without changing it' do
				expect(subject.replace_values(hash, filtered_keys, value))
					.to eq(hash)
			end
		end

		context 'taking a hash with a filter' do
			let(:filtered_keys) { [:a, :c] }
			let(:value) { "[___FILTERED___]" }

			it 'properly filters the hash' do
				expect(subject.replace_values(hash, filtered_keys, value))
					.to eq({:a => value, :b => hash[:b], :c => value})
			end
		end
	end


end
