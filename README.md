# Warden::OAuth2

This library provides a robust set of authorization strategies for
Warden meant to be used to implement an OAuth 2.0 ([draft 22][oauth2])
provider.

## Usage

```ruby
require 'warden-oauth2'

class MyAPI < Grape::API
  use Warden::Manager do |config|
    strategies.add :bearer, Warden::OAuth2::Strategies::Bearer
    strategies.add :client, Warden::OAuth2::Strategies::Client
    strategies.add :public, Warden::OAuth2::Strategies::Public

    config.default_strategies :bearer, :client, :public
  end
end
```

## Configuration

You can configure Warden::OAuth2 like so:

```ruby
Warden::OAuth2.configure do |config|
  config.some_option = some_value
end
```

### Configurable Options

* **client_model:** A client application class. See **Models** below.
  Defaults to `ClientApplication`.
* **token_model:** An access token class. See **Models** below. Defaults
  to `AccessToken`.

## Models

You will need to supply data models to back up the persistent facets of
your OAuth 2.0 implementation. Below are examples of the interfaces that
each require.

### Client Application

```ruby
class ClientApplication
  # REQUIRED
  def self.locate(client_id, client_secret = nil)
    # Should return a client application matching the client_id
    # provided, but should ONLY match client_secret if it is
    # provided.
  end
end
```

### Access Token

```ruby
class AccessToken
  # REQUIRED
  def self.locate(token_string)
    # Should return an access token matching the string provided.
    # Note that you MAY include expired access tokens in the result
    # of this method so long as you implement an instance #expired?
    # method.
  end

  # OPTIONAL
  def expired?
    # True if the access token has reached its expiration.
  end

  # OPTIONAL
  def scope?(scope)
    # True if the scope passed in (usually a symbol) has been authorized
    # for this access token.
  end
end
```

## Strategies

### Bearer

This strategy authenticates by trying to find an access token that is
supplied according to the OAuth 2.0 Bearer Token specification
([draft 8][oauth2-bearer]). It does this by first extracting the access
token in string form and then calling the `.locate` method on your
access token model (see **Configuration** above).

Token-based strategies will also fail if they are expired or lack
sufficient scope. See **Models** above.

**User:** The Warden user is set to the client application returned by
`.locate`.

### Client

This strategy authenticates an OAuth 2.0 client application directly for
endpoints that don't require a specific user. You might use this
strategy when you want to create an API for client statistics or if you
wish to rate limit based on a client application even for publicly
accessible endpoints.

**User:** The Warden user is set to the access token returned by `.locate`.

### Public

This strategy succeeds by default and only fails if the authentication
scope is set and is something other than `:public`.

**User:** The Warden user is set to `nil`.

[oauth2]: http://tools.ietf.org/html/draft-ietf-oauth-v2-22
[oauth2-bearer]: http://tools.ietf.org/html/draft-ietf-oauth-v2-bearer-08