require 'spec_helper'

describe 'lib/site/logger.rb' do

	it 'can be required without error' do
		expect do
			require 'site/logger'
		end.not_to raise_error
	end

end
