require 'spec_helper'

describe 'site/cache' do

	it 'can be required without error' do
		expect { require 'site/cache' }.not_to raise_error
	end

end

require 'site/cache'

describe Site::Cache do
end
