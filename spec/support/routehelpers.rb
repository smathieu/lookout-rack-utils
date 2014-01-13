require 'sinatra'

module RouteHelpers
  class Server < Sinatra::Base
    get '/test_route' do
      status 200
    end
  end

  def app
    Server.new
  end
end
