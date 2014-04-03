# Warden::OAuth2 [![Build Status](https://travis-ci.org/airservice/warden-oauth2.svg?branch=master)](https://travis-ci.org/airservice/warden-oauth2)

This is a fork of [original project](https://github.com/opperator/warden-oauth2) which is actually maintained.
This library provides a robust set of authorization strategies for
Warden meant to be used to implement an OAuth 2.0 (targeting RFC6749)
provider.

## Usage

### Grape API Example

```ruby
require 'grape'
require 'warden-oauth2'

class MyAPI < Grape::API
  use Warden::Manager do |config|
    config.strategies.add :bearer, Warden::OAuth2::Strategies::Bearer
    config.strategies.add :client_credentials, Warden::OAuth2::Strategies::ClientCredentials
    config.strategies.add :resource_owner_password_credentials, Warden::OAuth2::Strategies::ResourceOwnerPasswordCredentials
    config.strategies.add :issuing_access_token, Warden::OAuth2::Strategies::IssuingAccessToken
    config.strategies.add :accessing_protected_resource, Warden::OAuth2::Strategies::AccessingProtectedResource
    config.strategies.add :refresh_token, Warden::OAuth2::Strategies::RefreshToken

    config.default_strategies :client_credentials, :resource_owner_password_credentials, :refresh_token, :issuing_access_token
    config.default_strategies :bearer, :accessing_protected_resource
    config.failure_app Warden::OAuth2::FailureApp
  end

  helpers do
    def warden; env['warden'] end
  end

  resources :hamburgers do
    before do
      warden.authenticate! scope: :hamburgers
    end
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

* **client_credentials_model:** A client application class used for client credentials authentication. See **Models** below.
  Defaults to `ClientCredentialsApplication`.
* **resource_owner_password_credentials_model:** A client application class used for resource owner password authentication. See **Models** below.
  Defaults to `ResourceOwnerPasswordCredentialsApplication`.
* **refresh_token_model:** A refresh token application class used for refresh token authentication. See **Models** below. Defaults
  to `RefreshTokenApplication`.
* **token_model:** An access token class. See **Models** below. Defaults
  to `AccessToken`.
## Models

You will need to supply data models to back up the persistent facets of
your OAuth 2.0 implementation. Below are examples of the interfaces that
each require.

### Client Credentials Application

```ruby
class ClientCredentialsApplication
  # REQUIRED
  def self.locate(client_id, client_secret = nil)
    # Should return a client application matching the client_id
    # provided, but should ONLY match client_secret if it is
    # provided.
  end

  # OPTIONAL
  def scope?(scope)
    # True if the client should be able to access the scope passed
    # (usually a symbol) without having an access token.
  end
end
```

### Resource Owner Password Credentials Application

```ruby
class ResourceOwnerPasswordCredentialsApplication
  # REQUIRED
  def self.locate(client_id, client_secret = nil)
    # Should return a client application matching the client_id
    # provided, but should ONLY match client_secret if it is
    # provided.
    # the returned value should implement the following interface
    # def valid?(options={})
      # Use options[:username] and options[:password] to check
      # that specified credentials are valid
    # end
  end

  # OPTIONAL
  def scope?(scope)
    # True if the client should be able to access the scope passed
    # (usually a symbol) without having an access token.
  end
end
```

### Refresh Token Application

```ruby
class RefreshTokenApplication
  # REQUIRED
  def self.locate(client_id, client_secret = nil)
    # Should return a refresh token application matching the client_id
    # provided, but should ONLY match client_secret if it is
    # provided.
    # the returned value should implement the following interface
    # def valid?
      # Use options[:refresh_token] to check that specified refresh token is valid
    # end
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

### Client credentials

This strategy authenticates an OAuth 2.0 client application directly for
endpoints that don't require a specific user. You might use this
strategy when you want to create an API for client statistics or if you
wish to rate limit based on a client application even for publicly
accessible endpoints.

**User:** The Warden user is set to the access token returned by `.locate`.

### Resource Owner Password Credential

This strategy creates an access token for a user with matching credentials.
Use `.valid?` on the client application to determine if user credentials are correct.

**User:** The Warden user is set to the access token returned by `.locate`.

### Refresh Token

This strategy creates an new access token based on expired access token refresh token.
Use `.valid?` on the refresh token application to determine if refresh token is valid.

**User:** The Warden user is set to the access token returned by `.locate`.

### Issuing Access Token

This strategy is a fallback strategy when cannot issue access token due to unspecified grant_type

### Accessing Protected Resource

This strategy is a fallback strategy when cannot validate access to protected resource due to unspecified token

### Public

This strategy succeeds by default and only fails if the authentication
scope is set and is something other than `:public`.

**User:** The Warden user is set to `nil`.

[oauth2]: http://tools.ietf.org/html/draft-ietf-oauth-v2-22
[oauth2-bearer]: http://tools.ietf.org/html/draft-ietf-oauth-v2-bearer-08

## License
The MIT License

Copyright (c) 2014 AirService Pty Ltd. http://www.airservice.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
