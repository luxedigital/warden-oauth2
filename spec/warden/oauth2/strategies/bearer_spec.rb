require 'spec_helper'

describe Warden::OAuth2::Strategies::Bearer do
  let(:strategy) { Warden::OAuth2::Strategies::Bearer }
  let(:token_model) { double(:AccessToken) }
  subject { strategy.new('rack.input' => {}) }

  before do
    Warden::OAuth2.config.token_model = token_model
  end

  describe '#token_string_from_header' do
    Rack::Auth::AbstractRequest::AUTHORIZATION_KEYS.each do |key|
      it "should recognize a bearer token in the #{key} environment key" do
        allow(subject).to receive(:env).and_return(key => 'Bearer abc')
        expect(subject.token_string_from_header).to eq('abc')
      end
    end

    it 'should ignore a non-bearer authorization header' do
      allow(subject).to receive(:env).and_return('HTTP_AUTHORIZATION' => 'Other do do do')
      expect(subject.token_string_from_header).to be_nil
    end
  end

  describe '#token_string_from_request_params' do
    it 'should pull the :access_token param' do
      allow(subject).to receive(:params).and_return('access_token' => 'abc')
      expect(subject.token_string_from_request_params).to eq('abc')
    end
  end
end
