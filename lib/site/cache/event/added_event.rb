require 'site/cache/event'

module Site

	class AddedEvent < Event

		def initialize(entry)
			super(entry)
		end

	end

end
