require 'listen'

module Site

	class Listener
		attr_reader :targets

		def initialize(commands: [], directories: [])
			@targets = []
		end
	end

end
