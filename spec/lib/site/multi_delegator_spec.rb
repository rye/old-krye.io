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

		{
			"valid": [:write, :close],
			"invalid": [:completely_fucking_invalid]
		}.each do |type_of_values, values|

			context "splatting an array of #{type_of_values} method names" do
				let :method_names do values end

				it 'does not raise an error' do
					allow(Site::MultiDelegator).to receive(:define_method)

					expect do
						Site::MultiDelegator.delegate(*method_names)
					end.not_to raise_error
				end

				it 'iterates over each method name and defines a method for each name' do
					allow(Site::MultiDelegator).to receive(:define_method)

					method_names.each do |expected_method_name|
						expect(Site::MultiDelegator).to receive(:define_method).with(expected_method_name)
					end

					Site::MultiDelegator.delegate(*method_names)
				end

			end

		end

	end

end
