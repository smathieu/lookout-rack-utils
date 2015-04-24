require 'zlib'

module Lookout::Rack::Utils
  module Request
    ILLEGAL_CHARS_REGEX = /[<>]/
    HTTP_CONTENT_ENCODING_KEY = "HTTP_CONTENT_ENCODING".freeze
    CONTENT_ENCODING_GZIPPED = "gzip".freeze

    # Return the raw, unprocessed request body
    #
    # @return  [String]
    def raw_body
      # Rewind the StringIO object in case somebody else read it first
      request.body.rewind
      return request.body.read
    end

    # Return the body, which is gunzipped only if the appropriate header is set on the request
    #
    # Will halt and create a a 400 status code if there is something wrong with
    # the body
    #
    # @return  [String]
    def gunzipped_body
      body = raw_body
      if request.env[HTTP_CONTENT_ENCODING_KEY] != CONTENT_ENCODING_GZIPPED
        return body
      else
        begin
          return gunzip(body)
        rescue Zlib::Error
          if defined?(Lookout::Rack::Utils::Log)
            Lookout::Rack::Utils::Log.instance.warn "Unzipping error when decompressing request body (#{body})"
          end
          halt 400, "{}"
        end
      end
    end

    # Process and parse the request body as JSON
    #
    # Will halt and create a a 400 status code if there is something wrong with
    # the body
    def body_as_json
      body = raw_body

      halt 400, { :error => t('error.body_was_nil') }.to_json if body.nil?
      halt 400, { :error => t('error.body_was_blank') }.to_json if body.blank?

      begin
        return JSON.parse(body)
      rescue JSON::ParserError
        if defined?(Lookout::Rack::Utils::Log)
          Lookout::Rack::Utils::Log.instance.warn "ParserError encountered parsing the request body (#{body})"
        end
        halt 400, "{}"
      end
    end

    private

    # Decompresses data
    #
    # @raise [Zlib::Error] if malformed data is provided
    # @return [String]
    def gunzip(data)
      # We set the window bits to MAX_WBITS + 32 to enable zlib and gzip decoding
      # with automatic header detection.
      zstream = Zlib::Inflate.new(Zlib::MAX_WBITS+32)
      begin
        decompressed = zstream.inflate(data)
      ensure
        zstream.close
      end
      decompressed
    end

  end
end
