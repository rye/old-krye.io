$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'site/logger'

module Rack
	class CommonLogger
		def log(env, status, headers, began_at)
			now = Time.now
			length = headers[CONTENT_LENGTH] ? (length.to_s == '0' ? '-' : length) : '-'

			Site::Logger.info "rack" do
				%{%s - %s [%s] "%s %s%s %s" %d %s %0.4f} %
					[
					 env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR'] || '-',
					 env['REMOTE_USER'] || '-',
					 now.strftime("%d/%b/%Y:%H:%M:%S %z"),
					 env['REQUEST_METHOD'],
					 env['PATH_INFO'],
					 env['QUERY_STRING'].empty? ? "" : "?#{env['QUERY_STRING']}",
					 env['HTTP_VERSION'],
					 status.to_s[0..3],
					 length,
					 now - began_at
					]
			end
		end
	end
end

require 'site'

Site::Server.prepare!

run Site::Server
