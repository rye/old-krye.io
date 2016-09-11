require 'site/cache/event'

module Site

	class AddedEvent < Event

		def initialize(filename)
			super(filename)
		end

	end

end
