module LookoutRackUtils
  module Request
    ILLEGAL_CHARS_REGEX = /[<>]/

    # Return the raw, unprocessed request body
    #
    # @return  [String]
    def raw_body
      # Rewind the StringIO object in case somebody else read it first
      request.body.rewind
      return request.body.read
    end

    # Process and parse the request body as JSON
    #
    # Will halt and create a a 400 status code if there is something wrong with
    # the body
    #
    def body_as_json
      body = raw_body

      halt 400, { :error => t('error.body_was_nil') }.to_json if body.nil?
      halt 400, { :error => t('error.body_was_blank') }.to_json if body.blank?

      begin
        return JSON.parse(body)
      rescue JSON::ParserError
        warn "ParserError encountered parsing the request body (#{body})"
        halt 400, "{}"
      end
    end
  end
end
