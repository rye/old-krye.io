require 'thread'
require 'securerandom'

module Site

	class WorkerPool

		attr_accessor :queue
		attr_reader :pool

		def initialize
			@queue = Queue.new
			@pool = []
		end

		def spawn(number_of_workers, worker_klass, &block)
			number_of_workers.times do |n|
				worker = worker_klass.new(self, SecureRandom.hex(8))
				@pool << worker
				worker.run(&block)
			end
		end

		def worker_threads
			@pool.map do |worker|
				worker.thread || nil
			end
		end

		def statuses
			worker_threads.map do |worker_thread|
				worker_thread.status
			end
		end

	end

end
