require 'spec_helper'

describe 'site/multi_delegator' do

	it 'can be required without error' do
		expect { require 'site/multi_delegator' }.not_to raise_error
	end

end

require 'site/multi_delegator'

describe Site::MultiDelegator do

	describe '.to' do

		it 'splats an Array of targets' do
			expect(Site::MultiDelegator.method(:to).arity).to be(-1)
		end

	end

	describe '.delegate' do

		it 'splats an Array of method names' do
			expect(Site::MultiDelegator.method(:delegate).arity).to be(-1)
		end

		# TODO: Test invalid method names
		context 'splatting an Array of valid method names' do

			let :valid_method_names do [:write, :close] end

			it 'iterates over each method name and defines a method for each name' do
				allow(Site::MultiDelegator).to receive(:define_method)

				valid_method_names.each do |method_name|
					expect(Site::MultiDelegator).to receive(:define_method).with(method_name)
				end

				Site::MultiDelegator.delegate(*valid_method_names)
			end

		end

	end

end
