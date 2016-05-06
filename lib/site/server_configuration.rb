require 'site/configuration'

module Site

	class ServerConfiguration < Configuration

		def initialize(filename)
			super(filename)
		end

		def environment
			sinatra['environment'].to_sym
		end

		def sessions?
			sinatra['sessions']
		end

		def logging?
			sinatra['logging']
		end

		def use_shitty_method_override?
			sinatra['method_override']
		end

		def root_folder
			File.join(File.dirname(@filename), sinatra['root'])
		end

		def serve_static?
			sinatra['static']
		end

		def public_folder
			dir = sinatra['public_folder']

			Proc.new { File.join root, dir }
		end

		def views_folder
			dir = sinatra['views_folder']

			Proc.new { File.join root, dir }
		end

		def bind
			sinatra['bind'] || 'localhost'
		end

		def port
			sinatra['port'] || 4567
		end

		def show_exceptions
			sinatra['show_exceptions'] || true
		end

		protected

		def settings
			self['settings'] || {}
		end

		def sinatra
			settings['sinatra'] || {}
		end

	end

end
