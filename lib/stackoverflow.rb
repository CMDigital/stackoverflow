require "stackoverflow/version"
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
      options ||= {}
      options[:site] = 'stackoverflow'
      options[:inname] = query

      response = self.class.get '/users', query: options
      response['items']
    end
  end
end
