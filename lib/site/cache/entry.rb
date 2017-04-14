require 'site'
require 'pathname'
require 'digest'
require 'mime-types'
require 'base64'

require 'tilt'

module Site

	class Entry < Hash

		attr_reader :filename

		@@git_describe ||= `git describe --tags --dirty`.chomp

		def self.root_directory
			Site::ROOT_DIRECTORY
		end

		def self.views_directory
			Site::VIEWS_DIRECTORY
		end

		def self.static_directory
			Site::STATIC_DIRECTORY
		end

		def self.encode(data)
			Base64.encode64(data)
		end

		def self.decode(data)
			Base64.decode64(data)
		end

		def self.digest(data)
			Digest::SHA1.base64digest(data)
		end

		def initialize(filename)
			@filename = filename
		end

		def tag(volatility = self.volatility)
			case volatility
			when :version
				"#{relative_path}-#{@@git_describe}"
			when :instance
				"#{relative_path}-#{Process.pid}-#{@@git_describe}"
			when :contents
				"#{relative_path}-#{digest}"
			else
				"#{relative_path}"
			end
		end

		def volatility
			self[:volatility] || default_volatility
		end

		def slug
			{"route": route, "aliases": aliases, "digest": digest, "data": encoded_contents}
		end

		def route
			self[:route] || default_route
		end

		def aliases
			self[:aliases] || []
		end

		def ttl
			self[:ttl] || default_ttl
		end

		def sha1_tag
			Entry.digest(tag)
		end

		def digest
			Entry.digest(contents)
		end

		def encoded_contents
			Entry.encode(contents)
		end

		def relative_path_from(directory)
			relative_path_between(directory, @filename)
		end

		def relative_path
			relative_path_from(Entry.root_directory)
		end

		def relative_path_from_parent(file = @filename, parent = self.parent)
			relative_path_from(parent)
		end

		def type(file = @filename)
			return :static if static?(file)
			return :view if view?(file)

			nil
		end

		def contents(**args)
			@contents if @contents

			if static?
				read!
			elsif view?
				render!(args)
			end
		end

		def mime_type
			MIME::Types.type_for(@filename)
		end

		def read!
			@contents ||= read(@filename)
		end

		def render!(**args)
			@contents ||= render(@filename, args)
		end

		protected

		def read(file = @filename)
			open(file, 'rb') do |io|
				io.read
			end
		end

		def default_volatility
			case type
			when :static
				:version
			when :view
				:instance
			else
				:contents
			end
		end

		def default_route
			case type
			when :static
				File.join('', relative_path_from_parent)
			when :view
				case mime_type.first.to_s
				when 'application/x-sass', 'application/x-scss'
					File.join('', relative_path_from_parent_without_extname(@filename) + '.css')
				when 'application/x-coffee'
					File.join('', relative_path_from_parent_without_extname(@filename) + '.js')
				when 'application/x-eruby'
					File.join('', relative_path_between(dirname(@filename), filename_without_extname(@filename)))
				else
					raise "Unknown mime_type #{mime_type}"
				end
			else
				raise "Unknown type #{type}"
			end
		end

		def default_ttl
			case volatility
			when :version
				604800
			when :contents
				86400
			when :instance
				60 # seconds
			else
				1 # seconds
			end
		end

		def parent(file = @filename)
			case type(file)
			when :static
				Entry.static_directory
			when :view
				Entry.views_directory
			end
		end

		def render(filename, **args)
			template = Tilt.new(filename, default_encoding: 'UTF-8')
			template.render(self, self.to_h.merge(args))
		end

		def static?(file = @filename)
			!(relative_path_between(Entry.static_directory, file).to_s =~ /^\.\.\//)
		end

		def view?(file = @filename)
			!(relative_path_between(Entry.views_directory, file).to_s =~ /^\.\.\//)
		end

		def dirname(file = @filename)
			File.dirname(file)
		end

		def extname(file = @filename)
			File.extname(file)
		end

		def relative_path_from_parent_without_extname(file = @filename)
			File.join(File.dirname(relative_path_from_parent(file)), File.basename(file, extname(file)))
		end

		def filename_without_extname(file = @filename)
			File.join(dirname(file), File.basename(file, extname(file)))
		end

		def relative_path_between(source, destination)
			Pathname.new(destination).relative_path_from(Pathname.new(source))
		end

	end

end
