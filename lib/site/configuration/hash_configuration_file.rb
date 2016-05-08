require 'yaml'
require 'site/configuration/readable'

require 'site/configuration/hash_configuration'

module Site
	module Configuration

		class HashConfigurationFile < HashConfiguration

			def initialize(filename)
				@filename = filename

				parse!
			end

			protected

			include Readable

			def parse(filename)
				data = read(filename)

				hash = YAML.load(data).to_h

				hash
			end

			def parse!
				merge!(parse(@filename))
			end

		end

	end
end
