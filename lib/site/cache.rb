require 'listen'
require 'mime-types'
require 'thread'
require 'fileutils'
require 'pathname'
require 'tilt'
require 'digest'
require 'colorize'

require 'site/cache/event/modified_event'
require 'site/cache/event/added_event'
require 'site/cache/event/removed_event'
require 'site/cache/file_entry'
require 'site/cache/worker_pool'
require 'site/cache/registry'

require 'site/logger'

module Site

	class Cache

		WORKER_COUNT = 4

		attr_reader :registry, :application

		def initialize(application:)
			register_mimes!

			@registry = Registry.new
			@application = application

			@worker_pool = CacheWorkerPool.new(@registry, @application)

			@listener = Listen.to(Site::STATIC_DIRECTORY, Site::VIEWS_DIRECTORY) do |modified, added, removed|
				on(modified, added, removed)
			end

			@listener.start

			spawn_workers!

			until @worker_pool.workers.map { |t| t.stop? }.uniq == [true]
				Site::Logger.info "waiting until all cache workers are sleepy to warm things up."
				sleep 0.1
			end

			Site::Logger.warn "warming the cache."

			warm(Site::STATIC_DIRECTORY)
			warm(Site::VIEWS_DIRECTORY)

			Site::Logger.warn "cache warmed; fs should eventually notify listeners."
		end

		def fetch(file)
			@registry.semaphore.synchronize do
				@registry[file] || nil
			end
		end

		def on(modified, added, removed)
			Site::Logger.info 'listener' do
				"received event with #{modified.count} modified; #{added.count} added; #{removed.count} removed files."
			end

			modified.each do |_modified|
				@worker_pool.dispatch(ModifiedEvent.new(File.expand_path(_modified)))
			end

			added.each do |_added|
				@worker_pool.dispatch(AddedEvent.new(File.expand_path(_added)))
			end

			removed.each do |_removed|
				@worker_pool.dispatch(RemovedEvent.new(File.expand_path(_removed)))
			end
		end

		def dump!
			@registry.semaphore.synchronize {
				{ registry: @registry, queue: @worker_pool.queue }
			}
		end

		protected

		def register_mimes!
			types = []

			types << MIME::Type.new('application/x-eruby') do |t|
				t.add_extensions 'html.erb'
				t.add_extensions 'rhtml'
				t.add_extensions 'erb'
			end

			types << MIME::Type.new('application/x-sass') do |t|
				t.add_extensions 'sass'
			end

			types << MIME::Type.new('application/x-scss') do |t|
				t.add_extensions 'scss'
			end

			types << MIME::Type.new('application/x-coffee') do |t|
				t.add_extensions 'coffee'
			end

			MIME::Types.add(types)
		end

		def warm(directory)
			Dir[File.join(directory, '**', '*')].each do |f|
				FileUtils.touch(f)
			end
		end

		def spawn_workers!
			@worker_pool.spawn_workers!(WORKER_COUNT)
		end

	end

end
