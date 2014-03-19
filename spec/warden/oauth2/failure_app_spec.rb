require 'spec_helper'

describe Warden::OAuth2::FailureApp do
  let(:app) { subject }
  let(:warden) { double(:winning_strategy => @strategy || strategy) }

  it 'uses empty string is strategy does not provide a description' do
    @strategy = double(error_status: 500,:message => 'custom', scope: 'bla')
    get '/unauthenticated', {}, 'warden' => warden
    last_response.body.should == '{"error":"custom","error_description":""}'
  end
  context 'with all info' do
    before do
      @strategy = double(:error_status => 502, :message => 'custom', error_description: 'description',
                         :scope => 'random')
      get '/unauthenticated', {}, 'warden' => warden
    end

    it 'should set the status from error_status if there is one' do
      last_response.status.should == 502
    end

    it 'should set the message and error description from the message' do
      last_response.body.should == '{"error":"custom","error_description":"description"}'
    end

    it 'should set the content type' do
      last_response.headers['Content-Type'].should == 'application/json'
    end

    it 'should set the X-OAuth-Accepted-Scopes header' do
      last_response.headers['X-Accepted-OAuth-Scopes'].should == 'random'
    end
  end
end
