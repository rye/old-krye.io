require 'spec_helper'

describe 'site/listener' do
	it 'can be required' do
		expect do require 'site/listener' end.not_to raise_error
	end
end

require 'site/listener'

describe Site::Listener do
	describe '#initialize' do
		context 'taking no arguments' do
			it 'does not raise an error' do
				expect { Site::Listener.new }.not_to raise_error
			end
		end
	end
end
