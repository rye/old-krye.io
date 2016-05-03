require 'site/configuration'

module Site

	class ServerConfiguration < Configuration

		def initialize(filename)
			super(filename)
		end

		def default_static_folder
			if self['static'] && self['static']['default']
				File.join(File.dirname(@filename), self['static']['default'])
			end
		end

	end

end
