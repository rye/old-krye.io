require 'yaml'

module Site

	class Configuration < Hash
		attr_reader :filename

		def initialize(filename)
			@filename = filename

			read!
		end

		protected

		def read(filename)
			data = open filename, 'rb' do |io|
				io.read
			end

			hash = YAML.load(data).to_h

			hash
		end

		def read!
			merge!(read(@filename))
		end
	end

end
