require 'spec_helper'

describe Warden::OAuth2::Strategies::AccessingProtectedResource do
  let(:strategy) { described_class }
  subject { strategy.new('rack.input' => {}) }

  describe '#valid?' do
    Rack::Auth::AbstractRequest::AUTHORIZATION_KEYS.each do |key|
      it 'returns true if token string is not correct' do
        allow(subject).to receive(:env).and_return(key => 'Some sneaky key')
        expect(subject).to be_valid
      end
    end
    it 'returns true if token string is not specified' do
      allow(subject).to receive(:env).and_return({})
      expect(subject).to be_valid
    end
    it 'returns false if token string is correct' do
      allow(subject).to receive(:env).and_return('HTTP_AUTHORIZATION' => 'Bearer abc')
      expect(subject).not_to be_valid
    end
  end
  describe '#authenticate!' do
    it 'fails with invalid_client' do
      subject._run!
      expect(subject.result).to eq(:failure)
      expect(subject.message).to eq('token_required')
      expect(subject.error_status).to eq(401)
      expect(subject.error_description).not_to be_empty
    end
  end
end
