module Lookout::Rack::Utils
  module Subroute
    def subroute!(relative_path, options={})
      options.each { |k,v| request.send(request.request_method)[k] = v }
      subcode, subheaders, body = call(env.merge('PATH_INFO' => relative_path))
      return [subcode, body.first]
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
