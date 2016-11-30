require 'sinatra/base'
require 'erb'

class LandingPage < Sinatra::Base

  def initialize
    super
    @paypal_link = ""
    @twitter_profile = "https://twitter.com/" + (ENV['TWITTER_PROFILE'] || "tlrasor")
    @github_profile = "https://github.com/" + (ENV['GITHUB_PROFILE'] || "tlrasor/cors-camel")
    @google_analytics_id = ENV['GOOGLE_ANALYTICS_ID'] || "UA-XXXXX-X"
  end

  get '*' do
    erb :index
  end

end