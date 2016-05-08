module Site
	module Configuration

		module Readable

			def read(filename)
				open(filename, 'rb') do |io|
					io.read
				end
			end

		end

	end
end
