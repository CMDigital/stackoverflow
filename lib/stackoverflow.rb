require "stackoverflow/version"
require "stackoverflow/errors"
require "httparty"

module Stackoverflow
  class << self
    attr_accessor :oauth_key
  end

  def self.configure
    yield self
  end

  class Client
    include HTTParty
    attr_reader :access_token

    base_uri 'https://api.stackexchange.com/2.1/'

    def initialize(access_token)
      @access_token = access_token
    end

    # Lookup users by name
    #
    # @param query [String] Name or part of the name of the user to look for.
    # @param options [Hash] Hash containing request options.
    # @option options [Integer] :page
    # @option options [Integer] :pagesize
    # @option options [Timestamp] :fromdate
    # @option options [Timestamp] :todate
    # @option options [String] :order
    # @option options [Integer] :min
    # @option options [Integer] :max
    # @option options [String] :sort
    # @see https://api.stackexchange.com/docs/users

    def users(query, options = {})
      options = default_options.merge(options || {})
      options[:inname] = query

      response = self.class.get '/users', query: options
      validate_response(response)

      response['items']
    end

    def default_options
      {
        site: 'stackoverflow',
        key: Stackoverflow.oauth_key,
        access_token: access_token
      }
    end

    def validate_response(response)
      return if response.code == 200

      message = response['error_message']
      id      = response['error_id']
      name    = response['error_name']

      case response['error_name']
      when 'throttle_violation'
        # It's a pity StackExchange API is not intended for non-human clients
        backoff = /available in (\d+) seconds/.match(message)[1].to_i
        raise Errors::ThrottleViolation.new(message, id: id, name: name, backoff: backoff)
      else
        raise Errors::Error.new(message, id: id, name: name)
      end
    end
  end
end
