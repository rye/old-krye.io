require 'spec_helper'

describe 'site/logger' do

	it 'can be required without error' do
		expect { require 'site/logger' }.not_to raise_error
	end

end

require 'site/logger'

describe Site do

	it 'has a Logger constant which is a ::Logger' do
		expect(Site.const_defined?(:Logger)).to eq(true)
		expect(Site::Logger).to be_a(::Logger)
	end

end
