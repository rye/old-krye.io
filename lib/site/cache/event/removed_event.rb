require 'site/cache/event'

module Site

	class RemovedEvent < Event

		def initialize(filename)
			super(filename)
		end

	end

end
