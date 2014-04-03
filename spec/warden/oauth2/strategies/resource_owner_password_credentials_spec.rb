require 'spec_helper'

describe Warden::OAuth2::Strategies::ResourceOwnerPasswordCredentials do
  let(:strategy){ described_class }
  let(:client_model){ double(:ClientApplication) }
  subject{ strategy.new({'rack.input' => {}}) }

  before do
    Warden::OAuth2.config.resource_owner_password_credentials_model = client_model
  end

  describe '#valid?' do
    it 'returns false if the grant type is not specified' do
      subject.stub(:params).and_return({})
      subject.should_not be_valid
    end

    it 'returns true if the grant type is password' do
      subject.stub(:params).and_return({'grant_type' => 'password'})
      subject.should be_valid
    end

    it 'returns false if the grant type is not password' do
      subject.stub(:params).and_return({'grant_type' => 'whatever'})
      subject.should_not be_valid
    end
  end

  describe '#authenticate!' do
    it 'should fail if a client is around but not valid' do
      client_instance = double(:client_instance, valid?: false)
      client_model.stub(locate: client_instance)
      subject.stub(:params).and_return('client_id' => 'awesome', 'username' => 'someuser', 'password' => 'incorrect')
      subject._run!
      subject.message.should == "invalid_client"
      subject.error_status.should == 401
    end
    it 'should fail if username and password are not provided' do
      client_model.stub(locate: double)
      subject.stub(:params).and_return('client_id' => 'awesome')
      subject._run!
      subject.message.should == "invalid_request"
      subject.error_status.should == 400
      subject.error_description.should_not be_empty
    end
    it 'should pass username and password to validation check' do
      client_instance = double(:client_instance)
      client_model.stub(locate: client_instance)
      subject.stub(:params).and_return('client_id' => 'awesome', 'username' => 'username', 'password' => 'password')

      client_instance.should_receive(:valid?).with(username: 'username', password: 'password').and_return(false)

      subject._run!
    end
    it 'should succeed if a client is around and valid' do
      client_instance = double(:client_instance, valid?: true)
      client_model.stub(locate: client_instance)
      subject.stub(:params).and_return('client_id' => 'awesome', 'username' => 'username', 'password' => 'correct')
      subject._run!
      subject.user.should == client_instance
      subject.result.should == :success
    end
  end
end
