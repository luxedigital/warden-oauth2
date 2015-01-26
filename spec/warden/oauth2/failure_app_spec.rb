require 'spec_helper'

describe Warden::OAuth2::FailureApp do
  let(:app) { subject }
  let(:warden) { double(:winning_strategy => @strategy) }

  it 'defaults to invalid_request if strategy is not found' do
    @strategy = nil
    get '/unauthenticated', {}, 'warden' => warden
    expect(last_response.status).to eq(400)
    expect(last_response.body).to eq('{"error":"invalid_request","error_description":"cannot determine authentication method"}')
  end
  it 'uses empty string is strategy does not provide a description' do
    @strategy = double(error_status: 500,:message => 'custom', scope: 'bla')
    get '/unauthenticated', {}, 'warden' => warden
    expect(last_response.body).to eq('{"error":"custom","error_description":""}')
  end
  context 'with all info' do
    before do
      @strategy = double(:error_status => 502, :message => 'custom', error_description: 'description',
                         :scope => 'random')
      get '/unauthenticated', {}, 'warden' => warden
    end

    it 'should set the status from error_status if there is one' do
      expect(last_response.status).to eq(502)
    end

    it 'should set the message and error description from the message' do
      expect(last_response.body).to eq('{"error":"custom","error_description":"description"}')
    end

    it 'should set the content type' do
      expect(last_response.headers['Content-Type']).to eq('application/json')
    end

    it 'should set the X-OAuth-Accepted-Scopes header' do
      expect(last_response.headers['X-Accepted-OAuth-Scopes']).to eq('random')
    end
  end
end
