require 'digest'
require 'net/http'

module Geetest
  autoload :Version, 'geetest/version'
  autoload :Config, 'geetest/config'
  class << self
    def establish_connection!(opts = {})
      Config.initialize_connect(opts)
    end

    def code
      "#{Config.settings[:get_uri]}?gt=#{Config.settings[:id]}"
    end

    def validate(opt)
      challenge = opt['geetest_challenge'] ||= nil
      validate = opt['geetest_validate'] ||= nil
      seccode = opt['geetest_seccode'] ||= nil
      return false if challenge.blank? || validate.blank? || seccode.blank?
      return false if validate != Digest::MD5.hexdigest("#{Config.settings[:key]}geetest#{challenge}")
      back = post(Config.settings[:valid_uri], seccode: seccode) rescue ''
      back == Digest::MD5.hexdigest(seccode)
    end

    def version
      Version
    end

    private

    def post(uri, data)
      uri = URI(uri)
      res = Net::HTTP.post_form(uri, data)
      res.body
    end
  end
end
