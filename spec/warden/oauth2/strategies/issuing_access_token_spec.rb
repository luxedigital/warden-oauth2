require 'spec_helper'

describe Warden::OAuth2::Strategies::IssuingAccessToken do
  let(:strategy){ described_class }
  subject{ strategy.new({'rack.input' => {}}) }

  describe '#valid?' do
    it 'returns false when grant_type is specified' do
      subject.stub(:params).and_return({'grant_type' => 'whatever'})
      subject.should_not be_valid
    end
    it 'returns true when the grant_type is not specified' do
      subject.stub(:params).and_return({})
      subject.should be_valid
    end
  end
  describe '#authenticate!' do
    it 'fails with invalid grant' do
      subject._run!
      subject.result.should == :failure
      subject.message.should == 'invalid_grant'
      subject.error_status.should == 400
      subject.error_description.should_not be_empty
    end
  end
end
