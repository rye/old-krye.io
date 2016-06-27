require 'digest'

require 'site/listening/target'

module Site
	module Listening

		class Command < Target
			def initialize(command)
				@command = command
			end

			def contents
				`#{@command}`
			end
		end

	end
end
