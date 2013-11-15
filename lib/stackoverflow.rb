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

    # Common options
    #
    # @param options [Hash] Hash containing request options.
    # @option options [Integer] :page
    # @option options [Integer] :pagesize
    # @option options [Timestamp] :fromdate
    # @option options [Timestamp] :todate
    # @option options [String] :order
    # @option options [Integer] :min
    # @option options [Integer] :max
    # @option options [String] :sort

    # Lookup users by name
    #
    # @param query [String] Name or part of the name of the user to look for.
    # @param options [Hash] Hash containing request options.
    # @see https://api.stackexchange.com/docs/users

    def users(query, options = {})
      options = default_options.merge(options || {})
      options[:inname] = query

      response = self.class.get '/users', query: options
      validate_response(response)

      response['items']
    end

    # Get the users identified by ids
    #
    # @param users_ids [Array] Ids of the users.
    # @param options [Hash] Hash containing request options.
    # https://api.stackexchange.com/docs/users-by-ids

    def users_by_ids(users_ids, options = {})
      ids = users_ids.join(';')
      options = default_options.merge(options || {})

      response = self.class.get "/users/#{ids}", query: options
      validate_response(response)

      response['items']
    end

    # Returns the tags the users identified in ids have been active in.
    #
    # @param users_ids [Array] Ids of the users.
    # @param options [Hash] Hash containing request options.
    # @see https://api.stackexchange.com/docs/tags-on-users

    def users_tags(users_ids, options = {})
      ids = users_ids.join(';')
      options = default_options.merge(options || {})

      response = self.class.get "/users/#{ids}/tags", query: options
      validate_response(response)

      response['items']
    end

    # Search for any questions which fit the given criteria
    #
    # @param options [Hash] Hash containing request options.
    # @option options [String] :q
    # @option options [Boolean] :accepted
    # @option options [Integer] :answers
    # @option options [String] :body
    # @option options [Boolean] :closed
    # @option options [Boolean] :migrated
    # @option options [Boolean] :notice
    # @option options [Array] :nottagged
    # @option options [Array] :tagged
    # @option options [String] :title
    # @option options [Integer] :user
    # @option options [String] :url
    # @option options [Integer] :views
    # @option options [Boolean] :wiki
    # @see https://api.stackexchange.com/docs/advanced-search

    def advanced_search(options)
      options = default_options.merge(options || {})

      if options[:tagged] && options[:tagged].is_a?(Array)
        options[:tagged] = options[:tagged].join(';')
      end

      if options[:nottagged] && options[:nottagged].is_a?(Array)
        options[:nottagged] = options[:nottagged].join(';')
      end

      response = self.class.get '/search/advanced', query: options
      validate_response(response)

      response['items']
    end

    # Get the answers to a set of questions identified by ids
    #
    # @param questions_ids [Array] Ids of the questions.
    # @param options [Hash] Hash containing request options.
    # @option options [Integer] :page
    # @option options [Integer] :pagesize
    # @option options [Timestamp] :fromdate
    # @option options [Timestamp] :todate
    # @option options [String] :order
    # @option options [Integer] :min
    # @option options [Integer] :max
    # @option options [String] :sort
    # @see https://api.stackexchange.com/docs/answers-on-questions

    def questions_answers(questions_ids, options = {})
      options = default_options.merge(options || {})
      ids = questions_ids.join(';')

      response = self.class.get  "/questions/#{ids}/answers", query: options
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
