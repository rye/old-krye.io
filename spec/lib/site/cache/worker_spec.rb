require 'spec_helper'

describe 'site/cache/worker' do

	it 'can be required without error' do
		expect { require 'site/cache/worker' }.not_to raise_error
	end

end

require 'site/cache/worker'

describe Site::CacheWorker do

	describe '#initialize' do
	end

end
