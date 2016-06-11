require 'listen'

module Site

	class Listener
		attr_reader :targets

		def initialize
			@targets = []
		end
	end

end
