require 'spec_helper'

describe 'lib/site/multi_delegator.rb' do

	it 'can be required without error' do
		expect do
			require 'site/multi_delegator'
		end.not_to raise_error
	end

end
