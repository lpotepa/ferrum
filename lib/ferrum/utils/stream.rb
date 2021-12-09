# frozen_string_literal: true

module Ferrum
  module Utils
    module Stream
      module_function

      def fetch(path:, encoding:, &block)
        if path.nil?
          stream_to_memory(encoding: encoding, &block)
        else
          stream_to_file(path: path, &block)
        end
      end

      def stream_to_file(path:, &block)
        File.open(path, "wb") { |f| stream_to(f, &block) }
        true
      end

      def stream_to_memory(encoding:, &block)
        data = String.new("") # Mutable string has << and compatible to File
        stream_to(data, &block)
        encoding == :base64 ? Base64.encode64(data) : data
      end

      def stream_to(output, &block)
        loop do
          result = block.call(stream_chunk: 128 * 1024)
          data_chunk = result["data"]
          data_chunk = Base64.decode64(data_chunk) if result["base64Encoded"]
          output << data_chunk
          break if result["eof"]
        end
      end
    end
  end
end
