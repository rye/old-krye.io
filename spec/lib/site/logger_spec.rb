require 'spec_helper'

describe 'site/logger' do

	it 'can be required without error' do
		expect { require 'site/logger' }.not_to raise_error
	end

end

require 'site/logger'

describe Site do

	it 'has a LOG_FILE constant' do
		expect(Site.const_defined?(:LOG_FILE)).to eq(true)
	end

	it 'has a Logger constant' do
		expect(Site.const_defined?(:Logger)).to eq(true)
	end

end

describe 'Site::Logger' do

	subject { Site::Logger }

	it 'is a ::Logger' do
		expect(subject).to be_a(::Logger)
	end

end

describe 'Site::LOG_FILE' do

	subject { Site::LOG_FILE }

	it 'is a File' do
		expect(subject).to be_a(File)
	end

	it 'is synchronized' do
		expect(subject.sync).to be(true)
	end

end
