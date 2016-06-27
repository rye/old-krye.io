require 'digest'

module Site
	module Listening

		module Listenable
			def contents
				''
			end

			def encode!
				self.encode(self.contents)
			end

			protected

			def encode(data, digest_klass = Digest::SHA1)
				digest_klass.base64digest(data)
			end
		end

	end
end
