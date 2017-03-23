require 'site/cache/event'

module Site

	class RemovedEvent < Event

		def initialize(entry)
			super(entry)
		end

	end

end
