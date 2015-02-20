$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib/')

require 'lookout/rack/utils'

require 'rspec'
require 'rspec/its'

require 'rack/test'

Dir["./spec/support/**/*.rb"].sort.each do |f|
  require f
end

RSpec.configure do |c|
  c.include(Rack::Test::Methods, :type => :route)
  c.include(RouteHelpers, :type => :route)
end
