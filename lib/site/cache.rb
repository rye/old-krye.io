require 'fileutils'
require 'digest'

require 'listen'
require 'tilt'

require 'site'

require 'site/logger'

require 'site/cache/event'
require 'site/cache/entry'
require 'site/cache/adapter'
require 'site/cache/redis_adapter'

require 'site/cache/worker_pool'
require 'site/cache/worker'

module Site

	class Cache

		def initialize(env: ENV, application:)
			@env, @application = env, application

			@adapter = RedisAdapter.new @env
			@listened_directories = [Site::STATIC_DIRECTORY, Site::VIEWS_DIRECTORY]

			@listener = Listen.to(*@listened_directories) do |modified, added, removed|
				dispatch(modified, added, removed)
			end

			@listener.start

			@worker_pool = WorkerPool.new
			@worker_pool.spawn(2, Worker) do |worker, event|
				case event
				when ModifiedEvent, AddedEvent
					entry = event.entry
					entry[:worker_id] = "worker-#{worker.id}"

					filename = entry.filename

					tag = entry.sha1_tag
					slug = entry.slug
					route = entry.route
					aliases = entry.aliases

					@adapter.store(tag, slug)
					@adapter.expire(tag, entry.ttl)
					@application.set_routes(filename, tag, route, aliases)
				end
			end

			sleep 0.1

			@listened_directories.each do |directory|
				warm(directory)

				sleep 0.1
			end
		end

		def get(filename, tag)
			begin
				result = @adapter.get(tag)

				raise RuntimeError, "Tag not in Redis" unless result

				result
			rescue RuntimeError => error
				Logger.dump_exception(error)

				entry = Entry.new(filename)
				entry[:worker_id] = "worker-SPECIAL"

				tag = entry.tag

				@adapter.store(tag, entry.slug)
				retry
			end
		end

		protected

		def dispatch(modified, added, removed)
			modified.each do |filename|
				@worker_pool.queue << ModifiedEvent.new(Entry.new(filename))
			end

			added.each do |filename|
				@worker_pool.queue << AddedEvent.new(Entry.new(filename))
			end

			removed.each do |filename|
				@worker_pool.queue << RemovedEvent.new(Entry.new(filename))
			end

			Logger.info("Cache#dispatch") do "~#{modified.count}, +#{added.count}, -#{removed.count}" end
		end

		def warm(directory)
			Dir[File.join(directory, '**', '*')].each do |f|
				FileUtils.touch(f)
			end
		end

	end

end
