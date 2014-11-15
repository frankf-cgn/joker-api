require 'httparty'
require 'active_support/core_ext/object/blank'

require File.expand_path('../errors', __FILE__)
require File.expand_path('../operations', __FILE__)

module JokerAPI
  class Client
    include HTTParty

    DEFAULT_RESULT_POLL_INTERVAL = 0.5
    @@result_poll_interval = nil

    # @param [Float,nil] interval
    def self.set_result_poll_interval(interval)
      @@result_poll_interval = interval
    end

    @@user_agent = nil
    def self.user_agent
      @@user_agent ||= begin
        engine  = defined?(RUBY_ENGINE)  ? RUBY_ENGINE.capitalize : "Ruby"
        "JokerAPI::Client/#{JokerAPI::VERSION} (#{engine} #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}/#{RUBY_PLATFORM})"
      end
    end

    attr_reader :balance, :tlds

    def initialize(username, password, host = 'dmapi.joker.com', options = {})
      @username, @password = username, password
      @default_options = options.merge(:base_uri => HTTParty.normalize_base_uri("https://#{host}"))

      @default_options[:headers] ||= {}
      @default_options[:headers]['User-Agent'] = self.class.user_agent

      @auth_sid = nil
      @balance = 0.00
      @tlds = []
    end

    def inspect
      "#<#{self.class.name} #{@default_options[:base_uri]} (#{@username})#{@auth_sid && " logged in"}>"
    end

    # @param [Float,nil] interval
    def set_result_poll_interval(interval)
      @result_poll_interval = interval
    end
    
    def with_result_poll_interval(interval)
      rpi = @result_poll_interval
      begin
        @result_poll_interval = interval
        return yield self
      ensure
        @result_poll_interval = rpi
      end
    end

    def login
      response = perform_request('login', {:username => @username, :password => @password})

      @auth_sid = response.auth_sid
      @balance = response.account_balance
      @tlds = response.body.split("\n").sort

      self
    end

    # Returns the last HTTP request sent
    # @return [String]
    def last_http_request
      req = last_response.request
      out = "#{req.http_method::METHOD} #{req.uri.request_uri}\n"
      out += "Host: #{req.uri.host}\nConnection: close\n"
      req.options[:headers].each do |header, value|
        out += header.capitalize.gsub(/\-([a-z])/) { |m| "-#{m[1].chr.upcase}" }
        out += ": #{value}\n"
      end

      out # we only do GET requests so no need to append body, add if needed
    end
    # Returns the last HTTP response sent
    # @return [String]
    def last_http_response
      resp = last_response.response
      out = "HTTP/#{resp.http_version} #{resp.code} #{resp.message}\n"
      resp.each_header do |header, value|
        out += header.capitalize.gsub(/\-([a-z])/) { |m| "-#{m[1].chr.upcase}" }
        out += ": #{value}\n"
      end

      out += "\n#{resp.body}"
    end

    # Returns the last response received.
    # @return [Response]
    def last_response
      @response
    end

    # Returns the last error received from a response
    # @return [Response::Error]
    def last_error
      @last_error
    end

    # Returns the number of seconds the last request/response took
    # @return [Float]
    def response_time
      @response_time
    end

    include Operations::QueryContactList
    include Operations::ContactCreate
    include Operations::ContactDelete
    include Operations::ContactModify

    include Operations::QueryDomainList
    include Operations::DomainDelete
    include Operations::DomainModify
    include Operations::DomainOwnerChange
    include Operations::DomainRegister
    include Operations::DomainRenew
    include Operations::DomainTransferIn
    include Operations::DomainTransferInReseller
    include Operations::DomainTransferGetAuthId

    include Operations::DomainLock
    include Operations::DomainUnlock

    include Operations::DomainGetProperty
    include Operations::DomainSetProperty

    include Operations::QueryNsList
    include Operations::NsCreate
    include Operations::NsDelete
    include Operations::NsModify

    include Operations::QueryWhois

    include Operations::ResultRetrieve
    
    include Operations::WhoisAccreditation

    # @param [String] domain Domain name
    # @param [Boolean] value Enable/disable autorenew
    # @see Operations::DomainSetProperty#domain_set_property
    def domain_autorenew(domain, value = nil)
      return domain_get_property(domain, 'autorenew') == "1" if value.nil?
      domain_set_property(domain, 'autorenew', value ? "1" : "0")
    end

    # @param [String] domain Domain name
    # @param [Boolean] value Enable/disable WHOIS opt out
    # @see Operations::DomainSetProperty#domain_set_property
    def domain_whois_optout(domain, value = nil)
      return domain_get_property(domain, 'whois-opt-out') == "1" if value.nil?
      domain_set_property(domain, 'whois-opt-out', value ? "1" : "0")
    end

    protected
      def default_options
        @default_options
      end
      def perform_request(path, query = {})
        path = "/request/#{path}"
        options = default_options.dup

        query = query.reject { |_,v| v.blank? }

        begin
          query = query.merge('auth-sid' => @auth_sid) if @auth_sid
          options = options.merge(:query => query) unless query.empty?

          response_data = stopwatch do
            self.class.get(path, options)
          end

          @response = Response.new(response_data)
          store_response_information(@response)

          @response
        rescue AuthorisationError
          login
          retry
        end
      end
      def store_response_information(response)
        @last_error = response.error if response.error?
        @balance = response.account_balance || @balance
      end

      def stopwatch
        start = Time.now.utc.to_f
        result = yield
        @response_time = Time.now.utc.to_f - start
        return result
      end

      def result_poll_interval
        (@result_poll_interval || @@result_poll_interval || DEFAULT_RESULT_POLL_INTERVAL).to_f
      end

      # @param [Response] response
      # @yield [result] Gives the 'result-retrieve' headers to the block
      # @yieldparam result [Hash] The 'result-retrieve' headers as a hash
      # @return [Object,Boolean] False on errors, whatever the block results on success
      def wait_for_result(response)
        tries = 0
        begin
          sleep result_poll_interval
          result = result_retrieve(response)
          tries += 1

          case result["Completion-Status"]
          when "ack"  # Request Processed
            return yield result
          when "?"    # Request still pending
            raise IncompleteRequest.new(response)
          else        # dunno really
            return false
          end
        rescue IncompleteRequest
          retry unless tries > 4
          raise
        end
      end
  end
end
