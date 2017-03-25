require 'spec_helper'

describe 'lib/site/cache/listener.rb' do

	it 'can be required without error' do
		expect do
			require 'site/cache/listener'
		end.not_to raise_error
	end

end
