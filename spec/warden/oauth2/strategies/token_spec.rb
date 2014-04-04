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
      token_model.should_receive(:locate).with('abc')
      subject.stub(:token_string).and_return('abc')
      subject.token
    end
  end

  describe '#authenticate!' do
    before do
      subject.stub(token_string: nil)
    end
    it 'should be successful if there is a token' do
      token_instance = double
      subject.stub(token_string: 'token_string')
      token_model.stub(:locate).with('token_string').and_return(token_instance)
      subject._run!
      subject.result.should == :success
      subject.user.should == token_instance
    end

    it 'should fail if there is no token located' do
      token_model.stub(locate: nil)
      subject._run!
      subject.result.should == :failure
      subject.message.should == 'invalid_token'
      subject.error_status.should == 401
    end

    it 'should fail if the access token is expired' do
      token_instance = double(:respond_to? => true, :expired? => true, :scope? => true)
      token_model.stub(locate: token_instance)
      subject._run!
      subject.result.should == :failure
      subject.message.should == 'invalid_token'
      subject.error_status.should == 401
    end

    it 'should fail if there is insufficient scope' do
      token_instance = double(:respond_to? => true, :expired? => false, :scope? => false)
      token_model.stub(locate: token_instance)
      subject.stub(:scope).and_return(:secret)
      subject._run!
      subject.result.should == :failure
      subject.message.should == 'invalid_scope'
      subject.error_status.should == 403
    end
  end
end
