$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'site/logger'

module Rack
	class CommonLogger

		def log(env, status, headers, began_at)
			now = Time.now
			length = headers[CONTENT_LENGTH] ? (length.to_s == '0' ? '-' : length) : '-'

			parsed = parse_env env

			Site::Logger.info "rack" do
				format_string %
					[
					 parsed[:remote_address],
					 parsed[:remote_user],
					 rack_datetime(now),
					 parsed[:request_method],
					 parsed[:request_path],
					 parsed[:query_string],
					 parsed[:http_version],
					 status.to_s[0..3],
					 length,
					 elapsed(began_at, now)
					]
			end
		end

		protected

		def format_string
			%{%s - %s [%s] "%s %s%s %s" %d %s %0.4f}
		end

		def parse_env(env)
			{
				remote_address: env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR'] || '-',
				remote_user: env['REMOTE_USER'] || '-',
				request_method: env['REQUEST_METHOD'],
				request_path: env['PATH_INFO'],
				query_string: env['QUERY_STRING'].empty? ? "" : "?#{env['QUERY_STRING']}",
				http_version: env['HTTP_VERSION']
			}
		end

		def rack_datetime(now)
			now.strftime("%d/%b/%Y:%H:%M:%S %z")
		end

		def elapsed(t0, t1)
			t1 - t0
		end
	end
end

require 'site'

Site::Server.prepare!

run Site::Server
