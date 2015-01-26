require 'spec_helper'

describe Warden::OAuth2::Strategies::RefreshToken do
  let(:strategy) { described_class }
  let(:client_model) { double(:RefreshTokenApplication) }
  subject { strategy.new('rack.input' => {}) }

  before do
    Warden::OAuth2.config.refresh_token_model = client_model
  end
  describe '#valid?' do
    it 'returns false if the grant type is not specified' do
      allow(subject).to receive(:params).and_return({})
      expect(subject).not_to be_valid
    end

    it 'returns true if the grant type is refresh_token' do
      allow(subject).to receive(:params).and_return('grant_type' => 'refresh_token')
      expect(subject).to be_valid
    end

    it 'returns false if the grant type is not password' do
      allow(subject).to receive(:params).and_return('grant_type' => 'whatever')
      expect(subject).not_to be_valid
    end
  end

  describe 'authenticate!' do
    it 'should fail if no refresh token provided' do
      allow(client_model).to receive_messages(locate: double)
      allow(subject).to receive(:params).and_return('client_id' => 'client_id')

      subject._run!

      expect(subject.result).to eq(:failure)
      expect(subject.message).to eq('invalid_request')
      expect(subject.error_status).to eq(400)
    end

    it 'should succeed if a client is around' do
      client_instance = double
      allow(client_instance).to receive(:valid?).with(refresh_token: 'some_token').and_return(true)
      allow(client_model).to receive(:locate).with('client_id', nil).and_return(client_instance)
      allow(subject).to receive(:params).and_return('client_id' => 'client_id', 'refresh_token' => 'some_token')
      subject._run!
      expect(subject.user).to eq(client_instance)
      expect(subject.result).to eq(:success)
    end

    it 'should fail if a client is not found' do
      allow(client_model).to receive_messages(locate: nil)
      allow(subject).to receive(:params).and_return('refresh_token' => 'some_token')
      subject._run!
      expect(subject.result).to eq(:failure)
      expect(subject.message).to eq('invalid_client')
    end

    it 'should fail if client is not valid' do
      client_instance = double(valid?: false)
      allow(client_model).to receive_messages(locate: client_instance)
      allow(subject).to receive(:params).and_return('client_id' => 'client_id', 'refresh_token' => 'some_token')
      subject._run!
      expect(subject.user).to eq(nil)
      expect(subject.result).to eq(:failure)
      expect(subject.message).to eq('invalid_token')
      expect(subject.error_description).not_to be_empty
      expect(subject.error_status).to eq(401)
    end
  end
end
