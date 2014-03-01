require 'spec_helper'

describe Lookout::Rack::Utils::Subroute, :type => :route do
  describe '#subroute' do
    let(:route) { '/test_route' }
    let(:original) { get route }

    subject(:subrouted) { get "/subrouted" }

    before :each do
      class RouteHelpers::Server
        include Lookout::Rack::Utils::Subroute
        get '/subrouted' do
          subroute!('/test_route')
        end

        get '/subrouted/:id' do |id|
          subroute!('/test_route', :id => id)
        end
      end
    end

    context "without params" do
      it 'should return the status code and body of the route' do
        expect([subrouted.status, subrouted.body]).to eql [original.status, original.body]
      end
    end

    context "with params" do
      let(:id) { 1 }
      let(:body) { { :key => 'value', :id => "#{id}" }.to_json }

      subject(:subrouted) { get "/subrouted/#{id}?key=value" }

      it 'should return expected value' do
        expect([subrouted.status, subrouted.body]).to eql [200, body]
      end
    end
  end

  describe '#succeeded?' do
    subject { SubrouteTestHelper.new.succeeded?(status) }
    context 'with status 200' do
      let(:status) { 200 }
      it { should be_true }
    end

    context 'with status 299' do
      let(:status) { 299 }
      it { should be_true }
    end

    context 'with a non-20x status' do
      let(:status) { 300 }
      it { should be_false }
    end
  end

  describe '#failed?' do
    subject { SubrouteTestHelper.new.failed?(status) }
    context 'with status 200' do
      let(:status) { 200 }
      it { should be_false }
    end

    context 'with status 299' do
      let(:status) { 299 }
      it { should be_false }
    end

    context 'with a non-20x status' do
      let(:status) { 300 }
      it { should be_true }
    end
  end
end
