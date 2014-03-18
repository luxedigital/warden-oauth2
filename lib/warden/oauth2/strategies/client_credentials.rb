require 'warden-oauth2'

module Warden
  module OAuth2
    module Strategies
      class ClientCredentials < Client
        def model
          Warden::OAuth2.config.client_credentials_model
        end
        def valid?
          params['grant_type'] == 'client_credentials'
        end
      end
    end
  end
end
