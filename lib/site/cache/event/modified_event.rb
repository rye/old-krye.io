require 'site/cache/event'

module Site

	class ModifiedEvent < Event

		def initialize(entry)
			super(entry)
		end

	end

end
