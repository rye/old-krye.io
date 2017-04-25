require 'thread'
require 'site/logger'

require 'site/cache/event'

module Site

	class Worker

		attr_reader :id, :thread

		@@printing_mutex ||= Mutex.new

		def initialize(pool, id)
			@pool, @id = pool, id
			@thread = nil

			Logger.debug("worker-#{id}") do "Initialized!" end
		end

		def handle_event(event)
			case event
			when AddedEvent, ModifiedEvent
			when RemovedEvent
			end
		end

		def run(&block)
			@thread = Thread.new do
				loop do
					begin
						event = @pool.queue.pop(true)

						t0 = Time.now

						print_mutex.synchronize do
							Logger.info("worker-#{id}") do "Handling event for #{event.entry.relative_path_from(Site.root_directory)}." end
						end

						block.call(self, event)

						t1 = Time.now

						print_mutex.synchronize do
							Logger.debug("worker-#{id}") do "Event handling completed. (#{t1 - t0}s)" end
						end
					rescue ThreadError => error
						sleep 1.0
						retry
					rescue Exception => error
						print_mutex.synchronize do
							Logger.dump_exception(error)
						end
					end
				end
			end
		end

		protected

		def print_mutex
			@@printing_mutex
		end

	end

end
