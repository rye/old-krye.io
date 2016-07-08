require 'digest/sha1'

module Site
	module Caching

		module Encodable
			protected

			def encode(data)
				Digest::SHA1.base64digest(data)
			end
		end

	end
end
