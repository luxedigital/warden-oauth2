require 'spec_helper'

describe Warden::OAuth2::Strategies::RefreshToken do
  let(:strategy){ described_class }
  let(:client_model){ double(:RefreshTokenApplication) }
  subject{ strategy.new({'rack.input' => {}}) }

  before do
    Warden::OAuth2.config.refresh_token_model = client_model
  end
  describe '#valid?' do
    it 'returns false if the grant type is not specified' do
      subject.stub(:params).and_return({})
      subject.should_not be_valid
    end

    it 'returns true if the grant type is refresh_token' do
      subject.stub(:params).and_return({'grant_type' => 'refresh_token'})
      subject.should be_valid
    end

    it 'returns false if the grant type is not password' do
      subject.stub(:params).and_return({'grant_type' => 'whatever'})
      subject.should_not be_valid
    end
  end


  describe 'authenticate!' do
    it 'should fail if no refresh token provided' do
      client_model.stub(locate: double)
      subject.stub(:params).and_return('client_id' => 'client_id')

      subject._run!

      subject.result.should == :failure
      subject.message.should == "invalid_request"
      subject.error_status.should == 400
    end

    it 'should succeed if a client is around' do
      client_instance = double
      client_instance.stub(:valid?).with(refresh_token: 'some_token').and_return(true)
      client_model.stub(:locate).with('client_id', nil).and_return(client_instance)
      subject.stub(:params).and_return('client_id' => 'client_id', 'refresh_token' => 'some_token')
      subject._run!
      subject.user.should == client_instance
      subject.result.should == :success
    end

    it 'should fail if a client is not found' do
      client_model.stub(locate: nil)
      subject.stub(:params).and_return('refresh_token' => 'some_token')
      subject._run!
      subject.result.should == :failure
      subject.message.should == "invalid_client"
    end

    it 'should fail if client is not valid' do
      client_instance = double(valid?: false)
      client_model.stub(locate: client_instance)
      subject.stub(:params).and_return('client_id' => 'client_id','refresh_token' => 'some_token')
      subject._run!
      subject.user.should == nil
      subject.result.should == :failure
      subject.message.should == "invalid_token"
      subject.error_description.should_not be_empty
      subject.error_status.should == 401
    end
  end
end
