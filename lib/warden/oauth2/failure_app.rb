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
        error_description = strategy.respond_to?(:error_description) ? strategy.error_description : ''

        body = {}
        body[:error] = strategy.message
        body[:error_description] = error_description
        body = JSON.dump(body)
        status = strategy.error_status
        headers = {'Content-Type' => 'application/json'}

        headers['X-Accepted-OAuth-Scopes'] = (strategy.scope || :public).to_s

        [status, headers, [body]]
      end
    end
  end
end
