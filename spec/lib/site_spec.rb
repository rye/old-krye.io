require 'spec_helper'

# The actual source code file for the entire site.
describe 'lib/site.rb' do

	it 'can be required without error' do
		expect do
			require 'site'
		end.not_to raise_error
	end

end
