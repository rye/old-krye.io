module Site

	class Event

		attr_reader :entry

		def initialize(entry)
			@entry = entry
		end

	end

end

require 'site/cache/event/modified_event'
require 'site/cache/event/added_event'
require 'site/cache/event/removed_event'
