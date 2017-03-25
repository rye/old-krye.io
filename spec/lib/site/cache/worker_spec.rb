require 'spec_helper'

describe 'lib/site/cache/worker.rb' do

	it 'can be required without error' do
		expect do
			require 'site/cache/worker'
		end.not_to raise_error
	end

end
