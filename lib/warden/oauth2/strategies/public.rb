require 'warden-oauth2'

module Warden
  module OAuth2
    module Strategies
      class Public < Base
        def authenticate!
          if scope && scope.to_sym != :public
            fail!('invalid_scope') && return
          end

          success! nil
        end

        def error_status
          401
        end
      end
    end
  end
end
