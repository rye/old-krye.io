require 'spec_helper'

describe 'lib/site/cache/worker_pool.rb' do

	it 'can be required without error' do
		expect do
			require 'site/cache/worker_pool'
		end.not_to raise_error
	end

end
