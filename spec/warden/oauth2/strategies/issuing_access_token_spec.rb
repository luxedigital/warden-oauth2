require 'spec_helper'

describe Warden::OAuth2::Strategies::IssuingAccessToken do
  let(:strategy){ described_class }
  subject{ strategy.new({'rack.input' => {}}) }

  describe '#valid?' do
    it 'returns false when grant_type is specified' do
      allow(subject).to receive(:params).and_return({'grant_type' => 'whatever'})
      expect(subject).not_to be_valid
    end
    it 'returns true when the grant_type is not specified' do
      allow(subject).to receive(:params).and_return({})
      expect(subject).to be_valid
    end
  end
  describe '#authenticate!' do
    it 'fails with invalid grant' do
      subject._run!
      expect(subject.result).to eq(:failure)
      expect(subject.message).to eq('invalid_grant')
      expect(subject.error_status).to eq(400)
      expect(subject.error_description).not_to be_empty
    end
  end
end
