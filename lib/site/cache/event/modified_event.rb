require 'site/cache/event'

module Site

	class ModifiedEvent < Event

		def initialize(filename)
			super(filename)
		end

	end

end
