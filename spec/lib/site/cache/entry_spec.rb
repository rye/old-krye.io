require 'spec_helper'

describe 'lib/site/cache/entry.rb' do

	it 'can be required without error' do
		expect do
			require 'site/cache/entry'
		end.not_to raise_error
	end

end
