require 'spec_helper'

describe 'lib/site/cache/entry.rb' do

	it 'can be required without error' do
		expect do
			require 'site/cache/entry'
		end.not_to raise_error
	end

end

require 'site/cache/entry'

describe 'Site::Entry' do

	subject do
		Site::Entry
	end

	[:root_directory, :views_directory, :static_directory].each do |method|
		describe ".#{method.to_s}" do
			context 'taking no arguments' do

				subject do
					Site::Entry.send(method)
				end

				it 'returns a valid directory' do
					expect(File.directory?(subject))
				end

			end
		end
	end

	it 'inherits from Hash' do
		expect(subject.ancestors).to include(Hash)
	end

end
