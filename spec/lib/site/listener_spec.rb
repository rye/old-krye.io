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

		context 'taking two keyword arguments :commands and :directories' do
			let(:commands) { [] }
			let(:directories) { [] }

			it 'does not raise an error' do
				expect { Site::Listener.new(commands: commands, directories: directories) }.not_to raise_error
			end

			subject do
				Site::Listener.new commands: commands, directories: directories
			end

			it 'creates an Array of targets with count equal to the number of commands + the number of directories' do
				expect(subject.targets).to be_a(Array)

				subject.targets.each do |target|
					expect(target).to be_a(Site::Target)
				end

				expect(subject.targets.count).to eq(commands.count + directories.count)
			end
		end
	end

end
