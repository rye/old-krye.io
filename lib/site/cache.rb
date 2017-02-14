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

			sleep(0.1)

			@listened_directories.each do |directory|
				warm(directory)
			end
		end

		def dispatch(modified, added, removed)
			modified.each do |file|
				handle_dispatch(entry = Entry.new(file), ModifiedEvent.new(entry.filename))
			end

			added.each do |file|
				handle_dispatch(entry = Entry.new(file), AddedEvent.new(entry.filename))
			end

			removed.each do |file|
				handle_dispatch(entry = Entry.new(file), RemovedEvent.new(entry.filename))
			end
		end

		def handle_event(event)
			case event
			when RemovedEvent
				handle_delete event
			when AddedEvent, ModifiedEvent
				handle_modified event
			end
		end

		def get(key)
			@adapter.get(key)
		end

		def set_entry(entry)
			slug = { sha: entry.encoded_contents, data: entry.contents }

			@adapter.store(entry.filename, slug)
		end

		protected

		def handle_delete(event)
			entry = Entry.new(event.filename)

			if @adapter.contains?(entry.filename)
				Logger.debug "cache#handle_event" do "#{entry.relative_path_from_root}: removing from cache, route delete" end
				t0 = Time.now
				@adapter.delete entry.filename
				@application.routes_delete(entry.routes)
				t1 = Time.now
				Logger.debug "cache#handle_event" do "ok (#{t1 - t0}s)" end
			else
				Logger.warn "cache#handle_event" do "attempting to remove #{entry.relative_path_from_root} but not in cache. skip, no route delete" end
			end
		end

		def handle_modified(event)
			entry = Entry.new(event.filename)

			if @adapter.contains?(entry.filename)
				slug = @adapter.get(entry.filename)

				if slug["sha"] == entry.encoded_contents
					Logger.debug "cache#handle_event" do "#{entry.relative_path_from_root}: already in cache; no change" end
				else
					Logger.debug "cache#handle_event" do "#{entry.relative_path_from_root}: already in cache; updating" end
					set_entry(entry)
					Logger.debug "cache#handle_event" do "ok (#{t1 - t0}s)" end
				end
			else
				Logger.warn "cache#handle_event" do "#{entry.relative_path_from_root}: not in cache, adding" end
				t0 = Time.now
				set_entry(entry)
				t1 = Time.now
				Logger.debug "cache#handle_event" do "ok (#{t1 - t0}s)" end
			end

			@application.routes_update(entry.routes, entry.filename)
		end

		def handle_dispatch(entry, event)
			Logger.info "cache#dispatch" do "#{event.class}: #{entry.relative_path_from_root}" end
			handle_event event
		end

		def warm(directory)
			Dir[File.join(directory, '**', '*')].each do |f|
				FileUtils.touch(f)
			end
		end

	end

end
