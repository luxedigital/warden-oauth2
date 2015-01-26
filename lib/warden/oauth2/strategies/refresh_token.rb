module Warden
  module OAuth2
    module Strategies
      class RefreshToken < Client
        def valid?
          params['grant_type'] == 'refresh_token'
        end

        protected

        def model
          Warden::OAuth2.config.refresh_token_model
        end

        def client_authenticated
          if params['refresh_token']
            valid_client = client.valid?(refresh_token: params['refresh_token'])
            if valid_client
              super
            else
              fail('invalid_token')
              self.error_description = 'provided refresh token is not valid'
            end
          else
            fail 'invalid_request'
            self.error_description = 'refresh token is not provided'
          end
        end
      end
    end
  end
end
