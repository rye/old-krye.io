require 'spec_helper'

describe 'site/listening/target' do
	it 'can be required' do
		expect do require 'site/listening/target' end.not_to raise_error
	end
end

require 'site/listening/target'

describe Site::Listening::Target do
	it 'includes Site::Listening::Listenable' do
		expect(Site::Listening::Target).to include(Site::Listening::Listenable)
	end
end
