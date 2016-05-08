require 'digest'

require 'pp'
require 'sass'
require 'listen'
require 'fileutils'
require 'pathname'

require 'site/logger'

module Site

	class Compiler
		attr_reader :root_directory
		attr_reader :output_directory
		attr_reader :skeleton_directory
		attr_reader :thread

		def initialize(root_directory, output_directory, skeleton_directory, **templates)
			@root_directory, @output_directory, @skeleton_directory = root_directory, output_directory, skeleton_directory
			@templates = templates

			@sha_cache = {}

			@thread = nil

			if File.directory?(@output_directory)
				Site::Logger.info('Compiler#initialize') { 'Deleting existing output directory...' }
				FileUtils.rm_rf(@output_directory)
			end

			Site::Logger.info('Compiler#initialize') { 'Creating output directory...' }
			FileUtils.mkdir_p(@output_directory)
		end

		def template_engines_supported
			@templates.keys
		end

		def template_directories
			@templates.values
		end

		def template_engine_supported?(template_engine)
			!!@templates[template_engine]
		end

		def compile!
			previous_sha_cache = @sha_cache

			sha_cache!

			current_sha_cache = @sha_cache

			difference = (current_sha_cache.to_a - previous_sha_cache.to_a).to_h

			Site::Logger.debug 'Compiler#compile!' do
				"Detected #{difference.keys.count} different files..."
			end

			difference.keys.each do |different_file|
				different_file_pathname = Pathname.new(different_file)
				relative_path = different_file_pathname.relative_path_from(Pathname.new(@root_directory))

				type = nil

				if Dir.glob(File.join(@skeleton_directory, '**', '*')).include?(different_file)
					type = :static
				else
					type = (@templates.select do |type, directory|
						        Dir.glob(File.join(directory, '**', '*')).include?(different_file)
					        end).keys.first
				end

				Site::Logger.debug 'Compiler#compile!' do
					"Compiling #{type} file #{relative_path}"
				end

				case type
				when :static
					original_file = different_file
					output_file = File.join(@output_directory, different_file_pathname.relative_path_from(Pathname.new(@skeleton_directory)))

					FileUtils.mkdir_p(File.dirname(output_file))
					FileUtils.cp(original_file, output_file)
				when :scss
					original_file = different_file
					output_file = File.join(@output_directory, different_file_pathname.relative_path_from(Pathname.new(@templates[type])))

					output_file_css = File.join(File.dirname(output_file), File.basename(output_file, File.extname(output_file))) + '.css'

					FileUtils.mkdir_p(File.dirname(output_file_css))

					original_file_data = open(original_file, 'rb') do |io|
						io.read
					end

					sass_engine = Sass::Engine.new(original_file_data, syntax: :scss)

					open(output_file_css, 'wb') do |io|
						io.write sass_engine.render
					end
				else
					Site::Logger.error 'Compiler#compile!' do
						"Unsupported type value #{type.inspect}"
					end
				end
			end
		end

		def source_directories
			([@skeleton_directory] + template_directories).select do |directory_|
				File.directory? directory_
			end
		end

		def run!
			@thread = Thread.new do

				listener = Listen.to(*source_directories) do |modified, added, removed|
					Site::Logger.debug '<listener>' do
						"Detected modifications as follows: ~#{modified.count}+#{added.count}-#{removed.count}; Will re-run compile!"
					end

					compile!
				end

				listener.start

				sleep
			end
		end

		protected

		def sha_cache(directory)
			inventory = {}

			files = Dir.glob(File.join(directory, '**', '*')).select do |file_or_directory|
				File.file?(file_or_directory) && File.readable?(file_or_directory)
			end

			files.each do |file|
				digest = Digest::SHA256.file file

				inventory[file] = digest.hexdigest
			end

			inventory
		end

		def sha_cache!
			@sha_cache = {}
			@sha_cache.merge!(sha_cache(@skeleton_directory))

			template_directories.each do |template_directory|
				@sha_cache.merge!(sha_cache(template_directory))
			end
		end
	end

end
