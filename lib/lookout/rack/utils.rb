require "lookout/rack/utils/version"

module Lookout
  module Rack
    module Utils
    end
  end
end

if RUBY_PLATFORM == 'java'
  # This is required because YAML is messed up and incompatible with our version
  # of Configatron under JRuby
  module Psych
    module Yecht
      # Silence warnings about redefining constant
      ::Psych::Yecht.send(:remove_const, :MergeKey) if Yecht.const_defined?(:MergeKey)
      MergeKey = nil
    end
  end
end

require 'lookout/rack/utils/graphite'
require 'lookout/rack/utils/i18n'
require 'lookout/rack/utils/log'
require 'lookout/rack/utils/request'
require 'lookout/rack/utils/subroute'
