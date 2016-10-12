require 'thread'
require 'pathname'

require 'site/cache/event'
require 'site/cache/file_entry'
require 'site/server'
require 'site'

module Site

	class CacheWorker < Thread

		attr_reader :id

		def initialize(id, registry, queue, application)
			@id, @registry, @queue, @application = id, registry, queue, application
			@program_string = "worker #{@id}"

			super do
				begin
					loop do
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
				rescue => e
					Site::Logger.fatal @program_string do
						"#{e.class}: #{e.message}\n\t" + e.backtrace.join("\n\t")
					end

					Thread.exit
				end
			end
		end

		def handle_event(event)
			entry = FileEntry.new(event.filename)

			case event
			when RemovedEvent
				relative_path_from_root = entry.relative_path_from_root

				Site::Logger.debug(@program_string) { "#{relative_path_from_root} was deleted; queuing #{relative_path_from_root} for registy deletion" }

				@registry.semaphore.synchronize do
					@registry.delete(entry.filename)

					Site::Logger.debug(@program_string) { "#{relative_path_from_root} was removed from the registry" }
				end
			when ModifiedEvent, AddedEvent
				routes = entry.routes

				if !routes
					Site::Logger.warn(@program_string) { "#{relative_path_from_root} did not generate any routes" }
				else
					Site::Logger.debug(@program_string) { "routes for #{entry.relative_path_from_root}: #{routes}" }

					routes.each do |route|
						@application.get(route) {
							etag entry.encoded_contents

							content_type MIME::Types.type_for(route).first.to_s

							entry.contents
						}
					end
				end

				@registry[entry.filename] = entry
			end
		end

	end

end
