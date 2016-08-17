require 'listen'
require 'mime-types'
require 'thread'
require 'fileutils'
require 'pathname'
require 'tilt'
require 'digest'
require 'colorize'

require 'site/logger'

module Site

	class Cache

		WORKER_COUNT = 4

		attr_reader :entries, :static_directory, :views_directory, :application

		def initialize(application:,static:, views:)
			register_mimes!

			@workers ||= []
			@queue ||= Queue.new
			@entries ||= {}
			@semaphore = Mutex.new

			@application = application

			@static_directory = static
			@views_directory = views

			@listener = Listen.to(@static_directory, @views_directory) do |modified, added, removed|
				on(modified, added, removed)
			end

			@listener.start

			spawn_workers!

			until @workers.map { |t| t.stop? }.uniq == [true]
				Site::Logger.info "Waiting until all cache workers are sleepy to warm things up."
				sleep 0.1
			end

			Site::Logger.warn "Warming the cache."

			warm(static)
			warm(views)

			Site::Logger.warn "Cache warmed.  FS should eventually notify listeners."
		end

		def fetch(file)
			@semaphore.synchronize do
				@entries[file] || nil
			end
		end

		def on(modified, added, removed)
			Site::Logger.warn('listener') do
				"Received event with #{modified.count} modified; #{added.count} added; #{removed.count} removed files."
			end

			modified.each do |_modified|
				@queue << { nature: :modified, file: _modified }
			end

			added.each do |_added|
				@queue << { nature: :added, file: _added }
			end

			removed.each do |_removed|
				@queue << { nature: :removed, file: _removed }
			end
		end

		def dump!
			@semaphore.synchronize {
				{ hash: @entries, queue: @queue }
			}
		end

		protected

		def register_mimes!
			types = []

			types << MIME::Type.new('x-krye-io/x-eruby') do |t|
				t.add_extensions 'html.erb'
				t.add_extensions 'rhtml'
				t.add_extensions 'erb'
			end

			types << MIME::Type.new('x-krye-io/x-sass') do |t|
				t.add_extensions 'sass'
			end

			types << MIME::Type.new('x-krye-io/x-scss') do |t|
				t.add_extensions 'scss'
			end

			types << MIME::Type.new('x-krye-io/x-coffee') do |t|
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
							readable_file = Pathname.new(file).relative_path_from(Pathname.new(Site::ROOT_DIRECTORY)).to_s
							mime_types = MIME::Types.type_for(file).sort_by { |e| [e.media_type == 'x-krye-io' ? 0 : 1] }

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
								when 'x-krye-io/x-sass', 'x-krye-io/x-scss', 'x-krye-io/x-coffee', 'x-krye-io/x-eruby'
									Site::Logger.debug("Worker [#{worker_number}]") do
										"#{readable_file} is a recognized view format; rendering"
									end

									begin
										contents = Tilt.new(file, default_encoding: 'UTF-8').render
									rescue => error
										Site::Logger.error("Worker [#{worker_number}] (Tilt)") do
											"#{error.class}: #{error.message}\n\t" + error.backtrace.join("\n\t")
										end
									end
								else
									Site::Logger.debug("Worker [#{worker_number}]") do
										"#{readable_file} is not a recognized view; storing statically"
									end

									contents = open(file, 'rb') do |io|
										io.read
									end
								end

								encoded = Digest::SHA1.base64digest(contents)

								file_type, parent = case readable_file
								                    when /^static/
									                    [:static, @static_directory]
								                    when /^views/
									                    [:view, @views_directory]
								                    else
									                    [nil, Site::ROOT_DIRECTORY]
								                    end

								relative_path = Pathname.new(file).relative_path_from(Pathname.new(parent))

								Site::Logger.debug("Worker [#{worker_number}]") do
									"Waiting for Mutex lock to register routes for #{readable_file}"
								end

								@semaphore.synchronize {
									Site::Logger.debug("Worker [#{worker_number}]") do
										"Now registering routes for #{readable_file}"
									end

									routes = case file_type
									         when :static
										         [File.join('', relative_path)]
									         when :view
										         case primary_mime_type
										         when 'x-krye-io/x-sass', 'x-krye-io/x-scss'
											         [File.join('', File.join(File.dirname(relative_path), File.basename(relative_path, File.extname(relative_path)) + '.css'))]
										         when 'x-krye-io/x-coffee'
											         [File.join('', File.join(File.dirname(relative_path), File.basename(relative_path, File.extname(relative_path)) + '.js'))]
										         when 'x-krye-io/x-eruby'
											         filename = File.basename(relative_path, File.extname(relative_path))
											         dirname = File.dirname(relative_path)
											         base = Pathname.new(File.join(dirname, filename)).relative_path_from(Pathname.new(dirname))

											         ary = [File.join('', base)]
											         ary
										         end
									         else
									         end

									if !routes
										Site::Logger.warn("Worker [#{worker_number}]") do
											"#{readable_file} did not generate any routes!"
										end
									else
										completed_routes = routes.map do |_route|
											@application.get(_route) {
												entry = self.class.class_variable_get(:@@cache).entries[file]

												# Use the etag helper to set the current contents of the file.
												etag entry[:encoded]

												# Set the content type of the response.
												content_type MIME::Types.type_for(_route).first.to_s

												# Return the contents of the entry.
												entry[:contents]
											}
										end
									end

									@entries[file] = {
										readable: readable_file,
										encoded: encoded,
										contents: contents,
										mime_types: mime_types,
										type: file_type
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
