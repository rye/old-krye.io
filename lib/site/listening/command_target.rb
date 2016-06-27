require 'digest'

require 'site/listening/target'
require 'site/listening/listenable'

module Site
	module Listening

		class CommandTarget < Target
			def initialize(command)
				@command = command
			end

			def contents
				`@command`
			end
		end

	end
end
