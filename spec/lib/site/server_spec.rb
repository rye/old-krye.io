require 'spec_helper'

describe 'lib/site/server.rb' do

	it 'can be required without error' do
		expect do
			require 'site/server'
		end.not_to raise_error
	end

end
