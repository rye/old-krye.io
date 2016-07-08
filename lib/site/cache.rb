require 'listen'
require 'mime-types'
require 'thread'
require 'fileutils'
require 'pathname'
require 'tilt'
require 'digest'
require 'colorize'

module Site

	class Cache

		WORKER_COUNT = 4

		def initialize(root:, static:, views:)
			register_mimes!

			@listeners ||= []
			@workers ||= []
			@queue ||= Queue.new
			@entries ||= {}
			@semaphore = Mutex.new

			@root_directory = root
			@static_directory = static
			@views_directory = views

			@listeners << { directory: @static_directory, type: :static }
			@listeners << { directory: @views_directory, type: :views }

			@listeners.each do |listener|
				listener[:listener] = Listen.to(listener[:directory]) do |modified, added, removed|
					on(listener[:type], listener[:directory], modified, added, removed)
				end

				listener[:listener].start
			end

			spawn_workers!

			until @workers.map{|t|t.stop?}.uniq == [true]
				Site::Logger.info "Waiting until all cache workers are sleepy to warm things up."
				sleep 0.1
			end

			Site::Logger.warn "Warming the cache."

			warm(static)
			warm(views)
		end

		def fetch(file)
			@semaphore.synchronize do
				@entries[file] || nil
			end
		end


		def on(type, base_directory, modified, added, removed)
			modified.each do |_modified|
				@queue << {type: type, listening: base_directory, nature: :modified, file: _modified}
			end

			added.each do |_added|
				@queue << {type: type, listening: base_directory, nature: :added, file: _added}
			end

			removed.each do |_removed|
				@queue << {type: type, listening: base_directory, nature: :removed, file: _removed}
			end
		end

		def dump!
			@semaphore.synchronize {
				{ hash: @entries }
			}
		end

		protected

		def register_mimes!
			types = []

			types << MIME::Type.new('application/x-eruby') do
				|t|
				t.add_extensions 'html.erb'
				t.add_extensions 'rhtml'
				t.add_extensions 'erb'
			end

			types << MIME::Type.new('application/x-sass') do
				|t|
				t.add_extensions 'sass'
			end

			types << MIME::Type.new('application/x-scss') do
				|t|
				t.add_extensions 'scss'
			end

			types << MIME::Type.new('application/x-coffee') do
				|t|
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
			@workers = spawn_workers(WORKER_COUNT)
		end

		def spawn_workers(n)
			n.times.map do |worker_number|
				Thread.new do
					begin
						loop do
							Site::Logger.debug("Worker [#{worker_number}]") do
							 	"Waiting for an event..."
							end

							event = @queue.pop

							file = event[:file]
							readable_file = Pathname.new(file).relative_path_from(Pathname.new(@root_directory)).to_s
							mime_types = MIME::Types.type_for(file)

							primary_mime_type = mime_types.first

							case event[:nature]
							when :removed
								Site::Logger.debug("Worker [#{worker_number}]") do
									"#{readable_file} was deleted; waiting to remove from the cache"
								end

								@semaphore.synchronize {
									Site::Logger.debug("Worker [#{worker_number}]") do
										"#{readable_file} being removed from the cache"
									end

									@entries.delete(event[:file])

									Site::Logger.debug("Worker [#{worker_number}]") do
										"#{readable_file} removed"
									end
								}
							else
								contents = nil

								case primary_mime_type
								when 'application/x-sass', 'application/x-scss', 'application/x-coffee', 'application/x-eruby'
									Site::Logger.debug("Worker [#{worker_number}]") do
										"#{readable_file} is a recognized view format; rendering"
									end

									contents = Tilt.new(file, default_encoding: 'UTF-8').render
								else
									Site::Logger.debug("Worker [#{worker_number}]") do
										"#{readable_file} is not a recognized view; storing statically"
									end

									contents = open(file, 'rb') do |io|
										io.read
									end
								end

								encoded = Digest::SHA1.base64digest(contents)

								@semaphore.synchronize {
									@entries[file] = {
										readable: readable_file, encoded: encoded, contents: contents, mime_types: mime_types
									}
								}
							end
						end
					rescue => e
						Site::Logger.fatal "Worker [#{worker_number}] EXITING" do
							"#{e.class}: #{e.message}\n\t" + e.backtrace.join("\n\t")
						end

						Thread.exit
					end
				end
			end
		end
	end

end
