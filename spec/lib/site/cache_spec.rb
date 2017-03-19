require 'spec_helper'

describe 'lib/site/cache.rb' do

	it 'can be required without error' do
		expect do
			require 'site/cache'
		end.not_to raise_error
	end

end
