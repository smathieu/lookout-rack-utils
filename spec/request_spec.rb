require 'spec_helper'
require 'lookout/rack/utils/request'
require 'zlib'

class TestHelper
  attr_accessor :request

  include Lookout::Rack::Utils::Request

  def initialize
  end
end


describe Lookout::Rack::Utils::Request do
  let(:helper) { TestHelper.new }
  let(:sample_data) {'i am groot'}
  let(:zipped_sample_data){Zlib::Deflate.deflate(sample_data)}

  describe '#gunzipped_body' do

    before :each do
      helper.request = Object.new
      helper.request.stub(:env).and_return({'HTTP_CONTENT_ENCODING' => 'gzip'})
      helper.request.stub(:body).and_return(double)
      helper.request.body.stub(:rewind).and_return(double)
    end

    it 'should unzip data zipped data properly' do
      helper.request.body.stub(:read).and_return(zipped_sample_data)
      expect(helper.gunzipped_body).to eq(sample_data)
    end

    it 'should do nothing if encoding is not set' do
      helper.request.stub(:env).and_return({})
      helper.request.body.stub(:read).and_return(zipped_sample_data)
      expect(helper.gunzipped_body).to eq(zipped_sample_data)
    end

    it 'should halt and throw and 400 when we have badly encoded data' do
      helper.request.body.stub(:read).and_return(sample_data)
      expect(helper).to receive(:halt).with(400, "{}")
      helper.gunzipped_body
    end
  end

end
