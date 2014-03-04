require 'sinatra'

module RouteHelpers
  class Server < Sinatra::Base
    get '/test_route' do
      status 200
      params.to_json
    end
  end

  def app
    Server.new
  end
end
