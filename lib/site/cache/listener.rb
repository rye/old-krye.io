require 'listen'

module Site

	class Listener

		attr_accessor :callback

		attr_reader :directories

		def initialize(*directories)
			@directories = directories
		end

		def listen!(&callback)
			@callback = callback

			@listener = listen(@directories, &@callback)
		end

		def start
			@listener.start
		end

		protected

		def listen(directories, &callback)
			Listen.to(*@directories) do |modified, added, removed|
				callback.call(modified, added, removed)
			end
		end

	end

end
