require 'thread'
require 'pathname'

require 'site/cache/event'
require 'site/cache/file_entry'
require 'site/server'
require 'site'

module Site

	class CacheWorker < Thread

		NOOP = false

		attr_reader :id

		def initialize(id, registry, queue, application)
			@id, @registry, @queue, @application = id, registry, queue, application
			@program_string = "worker #{@id}"

			super do
				begin
					loop do
						if NOOP
							Site::Logger.warn @program_string do
								"NOOP"
							end

							sleep rand
						else
							Site::Logger.debug @program_string do
								"waiting for event"
							end

							event = @queue.pop

							Site::Logger.debug @program_string do
								"popped event: #{event.inspect}"
							end

							handle_event(event)

							Site::Logger.debug @program_string do
								"event handling finished"
							end
						end
					end
				rescue => e
					Site::Logger.fatal @program_string do
						"#{e.class}: #{e.message}\n\t" + e.backtrace.join("\n\t")
					end

					Thread.exit
				end
			end
		end

		def handle_event(event)
			case event
			when RemovedEvent
				entry = FileEntry.new(event.filename)
				relative_path_from_root = entry.relative_path_from_root

				Site::Logger.debug @program_string do
					"#{relative_path_from_root} was deleted; waiting to remove from registry"
				end

				@registry.semaphore.synchronize do
					Site::Logger.debug @program_string do
						"removing #{relative_path_from_root} from the registry"
					end

					@registry.delete(entry.filename)

					Site::Logger.debug @program_string do
						"#{relative_path_from_root} was removed from the registry"
					end
				end
			when ModifiedEvent, AddedEvent
				entry = FileEntry.new(event.filename)

				routes = entry.routes

				if !routes
					Site::Logger.warn @program_string do
						"#{relative_path_from_root} did not generate any routes"
					end
				else
					Site::Logger.debug "routes for #{entry.relative_path_from_root}: #{routes}"

					routes.each do |_route|
						@application.get(_route) {
							etag entry.encoded_contents

							content_type MIME::Types.type_for(_route).first.to_s

							entry.contents
						}
					end
				end

				@registry[entry.filename] = entry
			else
				raise "invalid event"
			end
		end

	end

end