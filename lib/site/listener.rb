require 'listen'

module Site

	class Listener
		attr_reader :targets

		def initialize(*targets)
			@targets = targets
		end
	end

end
