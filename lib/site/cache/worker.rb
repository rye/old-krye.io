require 'thread'
require 'pathname'

require 'site'

module Site

	class CacheWorker < Thread

		NOOP = false

		attr_reader :id

		def initialize(id, queue)
			@id, @queue = id, queue
			@program_string = "worker #{@id}"

			super do
				begin
					loop do
						if NOOP
							Site::Logger.error @program_string do
								"NOOP #{self}"
							end

							sleep rand
						else
							Site::Logger.debug @program_string do
								"Waiting for an event..."
							end

							event = @queue.pop

							Site::Logger.info @program_string do
								"event.inspect: #{event.inspect}"
							end

							handle_event(event)
						end
					end
				rescue => e
					Site::Logger.fatal "#{@program_string} EXITING" do
						"#{e.class}: #{e.message}\n\t" + e.backtrace.join("\n\t")
					end

					Thread.exit
				end
			end
		end

		def handle_event(event)
			Site::Logger.warn @program_string do
				"EVENT HANDLING"
			end
		end

	end

end
