require 'fileutils'
require 'digest'

require 'redis'
require 'listen'
require 'mime-types'
require 'tilt'

require 'site/cache/event'
require 'site/cache/entry'
require 'site/logger'

module Site

	class Cache

		def initialize(env: ENV, application:)
			register_mimes!

			@env, @application = env, application

			redis_host = ENV["REDIS_HOST"]
			redis_port = ENV["REDIS_PORT"]
			redis_password = ENV["REDIS_PASSWORD"]

			redis_opts = {}

			redis_opts[:host] = redis_host if redis_host
			redis_opts[:port] = redis_port if redis_port
			redis_opts[:password] = redis_password if redis_password

			redis_opts.tap do |hash|
				filter_keys = [:password]

				printable_opts = hash.map do |key, value|
					filter_keys.include?(key) ? [key, "[FILTERED]"] : [key, value]
				end.to_h

				Logger.info "cache" do
					"Connecting to redis with opts #{printable_opts}"
				end
			end

			@listener = Listen.to(Site::STATIC_DIRECTORY, Site::VIEWS_DIRECTORY) do |modified, added, removed|
				dispatch(modified, added, removed)
			end

			@listener.start

			sleep(0.1)

			warm(Site::STATIC_DIRECTORY)
			warm(Site::VIEWS_DIRECTORY)

			@redis = Redis.new redis_opts
		end

		def dispatch(modified, added, removed)

			modified.each do |file|
				entry = Entry.new(file)
				Logger.info "cache#dispatch" do "modified: #{entry.relative_path_from_root}" end
				handle_event ModifiedEvent.new(entry.filename)
			end

			added.each do |file|
				entry = Entry.new(file)
				Logger.info "cache#dispatch" do "added: #{entry.relative_path_from_root}" end
				handle_event AddedEvent.new(entry.filename)
			end

			removed.each do |file|
				entry = Entry.new(file)
				Logger.info "cache#dispatch" do "removed: #{entry.relative_path_from_root}" end
				handle_event RemovedEvent.new(entry.filename)
			end
		end

		def handle_event(event)
			entry = Entry.new(event.filename)

			case event
			when RemovedEvent
				if contains?(entry.filename)
					Logger.debug "cache#handle_event" do "#{entry.relative_path_from_root}: removing from cache, route delete" end
					t0 = Time.now
					@redis.delete entry.filename
					@application.routes_delete(entry.routes)
					t1 = Time.now
					Logger.debug "cache#handle_event" do "ok (#{t1 - t0}s)" end
				else
					Logger.warn "cache#handle_event" do "attempting to remove #{entry.relative_path_from_root} but not in cache. skip, no route delete" end
				end
			when AddedEvent, ModifiedEvent
				if slug = get(entry.filename)
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
		end

		def set_entry(entry)
			slug = { sha: entry.encoded_contents, data: entry.contents }

			store(entry.filename, slug)
		end

		def store(key, object)
			data = JSON.generate(object)

			Logger.debug "cache#store" do "writing #{data.length} bytes" end

			@redis.set key, data
		end

		def contains?(key)
			@redis.exists key
		end

		def get(key)
			data = @redis.get key
			JSON.parse(data) if data
		end

		def dump!
			Logger.info "cache#dump!" do "Beginning dump!" end

			keys = @redis.keys

			Logger.info "cache#dump!" do "Have #{keys.count} keys..." end

			keys.each do |key|
				value = @redis.get key
				Logger.debug "cache#dump!" do "  #{key} => #{value}" end
			end
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

	end

end
