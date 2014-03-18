require 'warden'
require 'warden/oauth2/version'

module Warden
  module OAuth2
    class Configuration
      attr_accessor :client_credentials_model, :resource_owner_password_credentials_model, :token_model

      def initialize
        self.client_credentials_model = ClientCredentialsApplication if defined?(ClientCredentialsApplication)
        self.resource_owner_password_credentials_model = ResourceOwnerPasswordCredentialsApplication if defined?(ResourceOwnerPasswordCredentialsApplication)
        self.token_model = AccessToken if defined?(AccessToken)
      end
    end

    def self.config
      @@config ||= Configuration.new
    end

    def self.configure
      yield config
    end

    autoload :FailureApp, 'warden/oauth2/failure_app'
    module Strategies
      autoload :Base,   'warden/oauth2/strategies/base'
      autoload :Public, 'warden/oauth2/strategies/public'
      autoload :Token,  'warden/oauth2/strategies/token'
      autoload :Client, 'warden/oauth2/strategies/client'
      autoload :ClientCredentials, 'warden/oauth2/strategies/client_credentials'
      autoload :ResourceOwnerPasswordCredentials, 'warden/oauth2/strategies/resource_owner_password_credentials'
      autoload :Bearer, 'warden/oauth2/strategies/bearer'
    end
  end
end
