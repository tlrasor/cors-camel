#!/usr/bin/env rackup
require 'rubygems'
require 'bundler'
Bundler.require

require 'rack/cors'
require 'rack/reverse_proxy'
require 'rack/attack'
require 'sinatra'
require 'active_support'

require './landing_page'

class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new 

  # Split on a comma with 0 or more spaces after it.
  # E.g. ENV['HEROKU_VARIABLE'] = "foo.com, bar.com"
  # spammers = ["foo.com", "bar.com"]
  banned = ENV['BLACKLIST'] || ""
  spammers = banned.split(/,\s*/)

  # Turn spammers array into a regexp
  spammer_regexp = Regexp.union(spammers) # /foo\.com|bar\.com/
  blocklist("block referer spam") do |request|
    request.referer =~ spammer_regexp
  end

  # Throttle all requests by IP (60rpm)
  throttle('req/ip/min', :limit => 300, :period => 5.minutes) do |req|
    req.ip unless (req.path.start_with?('/css') || req.path.start_with?('/js') || req.path.start_with?('/img') || req.path == '/')
  end
  # Throttle all requests by IP (4rps)
  throttle('req/ip/sec', :limit => 4, :period => 1.seconds) do |req|
    req.ip unless (req.path.start_with?('/css') || req.path.start_with?('/js') || req.path.start_with?('/img') || req.path == '/')
  end

  Rack::Attack.throttled_response = lambda do |env|
    now = Time.now
    match_data = env['rack.attack.match_data']

    headers = {
      'X-RateLimit-Limit' => match_data[:limit].to_s,
      'X-RateLimit-Remaining' => '0',
      'X-RateLimit-Reset' => (now + (match_data[:period] - now.to_i % match_data[:period])).to_s
    }

    [ 429, headers, ["Throttled\n"]]
  end
end

use Rack::Attack

use Rack::Cors do
  allow do
    origins '*'
    resource '*', :headers => :any, :methods => :get
  end
end

use Rack::ReverseProxy do
  # Set :preserve_host to true globally (default is true already)
  reverse_proxy_options preserve_host: true, matching: :first
  reverse_proxy '/http://(.*)', 'http://$1', :timeout => 1
  reverse_proxy '/https://(.*)', 'https://$1', :timeout => 1
end


run LandingPage