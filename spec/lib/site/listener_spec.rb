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

			subject do
				Site::Listener.new
			end

			it 'creates an empty Array of targets' do
				expect(subject.targets).to be_a(Array)
				expect(subject.targets.count).to be(0)
			end
		end
	end

end
