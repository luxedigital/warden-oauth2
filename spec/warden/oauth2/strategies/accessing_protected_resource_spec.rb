require 'spec_helper'

describe Warden::OAuth2::Strategies::AccessingProtectedResource do
  let(:strategy){ described_class }
  subject{ strategy.new({'rack.input' => {}}) }

  describe '#valid?' do
    Rack::Auth::AbstractRequest::AUTHORIZATION_KEYS.each do |key|
      it 'returns true if token string is not correct' do
        subject.stub(:env).and_return({key => 'Some sneaky key'})
        subject.should be_valid
      end
    end
    it 'returns true if token string is not specified' do
      subject.stub(:env).and_return({})
      subject.should be_valid
    end
    it 'returns false if token string is correct' do
      subject.stub(:env).and_return({'HTTP_AUTHORIZATION' => 'Bearer abc'})
      subject.should_not be_valid
    end
  end
  describe '#authenticate!' do
    it 'fails with invalid_client' do
      subject._run!
      subject.result.should == :failure
      subject.message.should == 'invalid_client'
      subject.error_status.should == 400
      subject.error_description.should_not be_empty
    end
  end
end
