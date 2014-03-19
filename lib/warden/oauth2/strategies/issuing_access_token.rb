require 'warden-oauth2'

module Warden
  module OAuth2
    module Strategies
      class IssuingAccessToken < Base
        def valid?
          !params.include?('grant_type')
        end

        def authenticate!
          self.error_description = 'grant_type is not specified or invalid'
          fail! 'invalid_grant'
        end
      end
    end
  end
end
