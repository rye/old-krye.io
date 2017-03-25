require 'spec_helper'

describe 'lib/site/cache/event/added_event.rb' do

	it 'can be required without error' do
		expect do
			require 'site/cache/event/added_event'
		end.not_to raise_error
	end

end
