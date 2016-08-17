require 'thread'

require 'site/cache/worker'

module Site

	class CacheWorkerPool

		attr_accessor :workers
		attr_accessor :queue

		def initialize
			@workers = []
			@queue ||= Queue.new
		end

		def dispatch(event)
			@queue << event
		end

		def spawn_workers!(n)
			@workers += spawn_workers(n)
		end

		protected

		def spawn_workers(n)
			n.times.map do |worker_number|
				CacheWorker.new(worker_number, @queue)
			end
		end

	end

end
