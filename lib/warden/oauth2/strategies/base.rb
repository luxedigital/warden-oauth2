require 'warden-oauth2'

module Warden
  module OAuth2
    module Strategies
      class Base < Warden::Strategies::Base
        attr_writer :error_description
        def store?
          false
        end

        def error_status
          400
        end

        def error_description
          @error_description || ''
        end
      end
    end
  end
end
