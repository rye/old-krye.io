require 'spec_helper'

describe 'lib/site/cache/redis_adapter.rb' do

	it 'can be required without error' do
		expect do
			require 'site/cache/redis_adapter'
		end.not_to raise_error
	end

end
