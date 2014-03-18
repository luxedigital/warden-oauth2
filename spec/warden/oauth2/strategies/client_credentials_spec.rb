require 'spec_helper'

describe Warden::OAuth2::Strategies::ClientCredentials do
  let(:strategy){ described_class }
  let(:client_credentials_model){ double(:ClientApplication) }
  subject{ strategy.new({'rack.input' => {}}) }

  before do
    Warden::OAuth2.config.client_credentials_model = client_credentials_model
  end

  describe '#valid?' do
    it 'returns false if the grant type is not specified' do
      subject.stub(:params).and_return({})
      subject.should_not be_valid
    end

    it 'returns true if the grant type is client_credentials' do
      subject.stub(:params).and_return({'grant_type' => 'client_credentials'})
      subject.should be_valid
    end

    it 'returns false if the grant type is not client_credentials' do
      subject.stub(:params).and_return({'grant_type' => 'whatever'})
      subject.should_not be_valid
    end
  end
end
