require 'warden-oauth2'
require 'base64'

module Warden
  module OAuth2
    module Strategies
      class ClientCredentials < Client
        def valid?
          params['grant_type'] == 'client_credentials'
        end
      end
    end
  end
end
