require 'digest'
require 'listen'

module Site

	class Listener
		attr_reader :targets

		def initialize(commands: [], directories: [])
			@targets = []
		end

		def encode(data)
			Digest::SHA256.base64digest(data)
		end
	end

end
