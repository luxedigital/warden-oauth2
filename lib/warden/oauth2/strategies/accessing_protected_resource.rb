require 'warden-oauth2'

module Warden
  module OAuth2
    module Strategies
      class AccessingProtectedResource < Bearer
        def valid?
          !super
        end

        def authenticate!
          self.error_description = 'Bearer Token is not provided'
          fail! 'token_required'
        end
      end
    end
  end
end
