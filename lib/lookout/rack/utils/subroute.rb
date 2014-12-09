module Lookout::Rack::Utils
  module Subroute
    HTTP_METHODS = %w(DELETE GET HEAD OPTIONS LINK PATCH POST PUT TRACE UNLINK).freeze

    def subroute!(relative_path, options={})
      # Create a copy of our App instance to preserve the state of the
      # caller's env hash
      subserver = dup
      request_opts = {'PATH_INFO' => relative_path}

      request_opts['REQUEST_METHOD'] = options.delete(:request_method).upcase if options[:request_method]
      http_verb = request_opts['REQUEST_METHOD'] || subserver.request.request_method

      raise ArgumentError, "Invalid http method: #{http_verb}" unless HTTP_METHODS.include?(http_verb)

      # modify rack environment using Rack::Request- store passed in key/value
      # pairs into hash associated with the parameters of the current http verb
      options.each { |k,v| subserver.request.update_param(k, v) }
      # Invoking Sinatra::Base#call! on our duplicated app instance. Sinatra's
      # call will dup the app instance and then call!, so skip Sinatra's dup
      # since we've done that here.
      subcode, subheaders, body = subserver.call!(env.merge(request_opts))
      return [subcode, subheaders, body.first]
    end

    # Returns true if the status given is 20x
    #
    # @param [Integer] status
    def succeeded?(status)
      status.is_a?(Fixnum) && (200..299).include?(status)
    end

    # Returns false if the status given is 20x
    #
    # @param [Integer] status
    def failed?(status)
      !succeeded?(status)
    end
  end
end
