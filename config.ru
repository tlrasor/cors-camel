
require 'rubygems'
require 'bundler'
Bundler.require

require 'rack/cors'
require 'rack/reverse_proxy'
require 'sinatra'

require './landing_page'

use Rack::Cors do
  allow do
    origins '*'
    resource '*', :headers => :any, :methods => :get
  end
end

use Rack::ReverseProxy do
  # Set :preserve_host to true globally (default is true already)
  reverse_proxy_options preserve_host: true, matching: :first
  reverse_proxy '/http://(.*)', 'http://$1', :timeout => 10
  reverse_proxy '/https://(.*)', 'https://$1', :timeout => 10
end


run LandingPage