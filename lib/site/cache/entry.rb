require 'site'
require 'pathname'
require 'digest'
require 'mime-types'
require 'base64'

require 'tilt'

module Site

	class Entry < Hash

		attr_reader :filename

		def initialize(filename)
			@filename = filename
		end

		def relative_path_from_root
			@relative_path_from_root ||= relative_path_from(Site::ROOT_DIRECTORY)
		end

		def relative_path_from_parent
			@relative_path_from_parent ||= relative_path_from(parent)
		end

		def encoded_contents
			Digest::SHA1.base64digest(contents)
		end

		def mime_types
			@mime_types ||= MIME::Types.type_for(@filename)
		end

		def routes
			case type
			when :static
				[File.join('', relative_path_from_parent)]
			when :view
				case mime_type
				when 'application/x-sass', 'application/x-scss'
					[File.join('', relative_path_from_parent_without_extname + '.css')]
				when 'application/x-coffee'
					[File.join('', relative_path_from_parent_without_extname + '.js')]
				when 'application/x-eruby'
					[File.join('', Pathname.new(filename_without_extname).relative_path_from(Pathname.new(dirname)))]
				else
					raise "unknown mime_type #{mime_type}"
				end
			else
				raise "unknown type #{type}"
			end
		end

		def contents
			case type
			when :view
				begin
					Base64.encode64(Tilt.new(@filename, default_encoding: 'UTF-8').render)
				rescue => error
					Site::Logger.error("tilt") { "#{error.class}: #{error.message}\n\t" + error.backtrace.join("\n\t") }
				end
			else
				Base64.encode64(open(@filename, 'rb') { |io| io.read })
			end
		end

		def mime_type
			@mime_type ||= mime_types.first
		end

		protected

		def relative_path_from(directory)
			Pathname.new(@filename).relative_path_from(Pathname.new(directory))
		end

		def parent
			@parent ||= case type
			            when :static
				            Site::STATIC_DIRECTORY
			            when :view
				            Site::VIEWS_DIRECTORY
			            else
				            Site::ROOT_DIRECTORY
			            end
		end

		def type
			@type ||= case relative_path_from_root.to_s
			          when /^static/
				          :static
			          when /^views/
				          :view
			          else
				          nil
			          end
		end

		def dirname
			@dirname ||= File.dirname(@filename)
		end

		def extname
			@extname ||= File.extname(@filename)
		end

		def relative_path_from_parent_without_extname
			@relative_path_from_parent_without_extname ||= File.join(File.dirname(relative_path_from_parent), File.basename(@filename, extname))
		end

		def filename_without_extname
			@filename_without_extname ||= File.join(dirname, File.basename(@filename, extname))
		end

	end

end
