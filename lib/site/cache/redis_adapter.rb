require 'redis'

require 'site/logger'

require 'site/cache/adapter'

module Site

	class RedisAdapter < Adapter

		def initialize(env)
			super(env)

			redis_opts = redis_options

			redis_opts.tap do |opts|
				filtered_opts = [:password]

				printable_opts = replace_values(opts, filtered_opts, "[FILTERED]")

				Logger.info "RedisAdapter#initialize" do
					"Connecting to Redis with opts #{printable_opts}"
				end
			end

			@redis = Redis.new(redis_opts)

			with_connection_guard(max_tries: 16, exit_status_on_fail: 1) do
				ping

				Logger.info "RedisAdapter#initialize" do "Redis PONG-ed, ready to roll..." end
			end
		end

		def with_connection_guard(*args, max_tries: 8, exit_status_on_fail: nil, sleep_period: 1.0, &block)
			try_count = 0

			begin
				try_count += 1

				return block.call(*args)
			rescue Redis::BaseConnectionError => e
				Logger.dump_exception e

				if try_count < max_tries
					Logger.warn "RedisAdapter#with_connection_guard" do "Sleeping #{sleep_period}s and trying again..." end

					sleep sleep_period

					retry
				else
					Logger.fatal "RedisAdapter#with_connection_guard" do "Number of failed tries (#{try_count}) meets or exceeds the maximum number of tries (#{max_tries})... aborting." end

					exit exit_status_on_fail.to_i if !!exit_status_on_fail
				end
			end
		end

		def store(key, object)
			data = JSON.generate(object)

			@redis.set key, data
		end

		def contains?(key)
			@redis.exists key
		end

		def get(key)
			data = @redis.get key

			JSON.parse(data) if data
		end

		def delete(key)
			@redis.delete key
		end

		def expire(key, ttl)
			@redis.expire(key, ttl)
		end

		def ping
			@redis.ping
		end

		protected

		# Replaces values in `hash` corresponding to any of the
		# `filtered_keys` with `new_value`.
		#
		# Useful for situations like filtering plaintext passwords.
		def replace_values(hash, filtered_keys = [], new_value = nil)
			hash.map do |key, value|
				(filtered_keys.include?(key) && new_value) ? [key, new_value] : [key, value]
			end.to_h
		end

		def redis_options(env = ENV)
			host = env['REDIS_HOST']
			port = env['REDIS_PORT']
			password = env['REDIS_PASSWORD']

			opts = {}
			opts[:host] = host if host
			opts[:port] = port if port
			opts[:password] = password if password

			opts
		end

	end

end
