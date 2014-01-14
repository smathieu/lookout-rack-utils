module Lookout
  module Rack
    module Utils
      VERSION = "1.0.#{ENV['BUILD_NUMBER'] || 'dev'}"
    end
  end
end
