require 'site/caching/encodable'

module Site
  module Caching

    class Entry

      include Encodable

      attr_reader :filename, :mime_type, :contents, :sha1

      def initialize(filename:, mime_type:)
        @filename, @mime_type = filename, mime_type

        encode!
      end

      def read!
        @contents = open(@filename, 'rb') do |io|
          io.read
        end
      end

      def encode!
        read!

        @sha1 = encode(@contents || '')
      end
    end

  end
end
