require 'spec_helper'

describe Warden::OAuth2::Strategies::Token do
  let(:token_model){ double }
  let(:strategy){ Warden::OAuth2::Strategies::Token }
  subject{ strategy.new({'rack.input' => {}}) }

  before do
    Warden::OAuth2.config.token_model = token_model
  end

  describe '#token' do
    it 'should call through to .locate on the token_class with the token string' do
      expect(token_model).to receive(:locate).with('abc')
      allow(subject).to receive(:token_string).and_return('abc')
      subject.token
    end
  end

  describe '#authenticate!' do
    before do
      allow(subject).to receive_messages(token_string: nil)
    end
    it 'should be successful if there is a token' do
      token_instance = double
      allow(subject).to receive_messages(token_string: 'token_string')
      allow(token_model).to receive(:locate).with('token_string').and_return(token_instance)
      subject._run!
      expect(subject.result).to eq(:success)
      expect(subject.user).to eq(token_instance)
    end

    it 'should fail if there is no token located' do
      allow(token_model).to receive_messages(locate: nil)
      subject._run!
      expect(subject.result).to eq(:failure)
      expect(subject.message).to eq('invalid_token')
      expect(subject.error_status).to eq(401)
    end

    it 'should fail if the access token is expired' do
      token_instance = double(:respond_to? => true, :expired? => true, :scope? => true)
      allow(token_model).to receive_messages(locate: token_instance)
      subject._run!
      expect(subject.result).to eq(:failure)
      expect(subject.message).to eq('invalid_token')
      expect(subject.error_status).to eq(401)
    end

    it 'should fail if there is insufficient scope' do
      token_instance = double(:respond_to? => true, :expired? => false, :scope? => false)
      allow(token_model).to receive_messages(locate: token_instance)
      allow(subject).to receive(:scope).and_return(:secret)
      subject._run!
      expect(subject.result).to eq(:failure)
      expect(subject.message).to eq('invalid_scope')
      expect(subject.error_status).to eq(403)
    end
  end
end
