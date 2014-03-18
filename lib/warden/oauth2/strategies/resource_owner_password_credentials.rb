require 'warden-oauth2'

module Warden
  module OAuth2
    module Strategies
      class ResourceOwnerPasswordCredentials< Client
        def valid?
          params['grant_type'] == 'password'
        end

        protected
        def model
          Warden::OAuth2.config.resource_owner_password_credentials_model
        end

        def client_authenticated
          if params['username'] && params['password']
            valid_client = client.valid?(username: params['username'], password: params['password'])
            valid_client ? super : fail("invalid_client")
          else
            fail "invalid_request"
            self.error_description = "username or password are not provided"
          end
        end
      end
    end
  end
end
