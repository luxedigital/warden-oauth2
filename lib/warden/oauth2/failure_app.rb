require 'json'
module Warden
  module OAuth2
    class FailureApp
      def self.call(env)
        new.call(env)
      end

      def call(env)
        warden = env['warden']
        strategy = warden.winning_strategy

        headers = { 'Content-Type' => 'application/json' }
        body = {}
        if strategy
          error_description = strategy.respond_to?(:error_description) ? strategy.error_description : ''
          body[:error] = strategy.message
          body[:error_description] = error_description
          status = strategy.error_status

          headers['X-Accepted-OAuth-Scopes'] = (strategy.scope || :public).to_s
        else
          status = 400
          body[:error] = 'invalid_request'
          body[:error_description] = 'cannot determine authentication method'
        end
        [status, headers, [JSON.dump(body)]]
      end
    end
  end
end
