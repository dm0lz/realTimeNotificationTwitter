require 'bundler/setup'
require 'sinatra'
require 'twitter'
require 'omniauth-twitter'
require 'pry'
require 'mongo'


class TwitterNotifications < Sinatra::Base

  APP_TOKEN   = 'qSXgYnfl9TQHL0rcRw'
  APP_SECRET  = 'zhzEDv12a87RimkvaisEi5IZvqISzEVmf2gDIJQCuw'

  Twitter.configure do |config|
    config.consumer_key     = APP_TOKEN
    config.consumer_secret  = APP_SECRET
  end

  use OmniAuth::Builder do 
    provider :twitter, APP_TOKEN, APP_SECRET
  end

  set :views, 'views'
  enable :sessions
  use Rack::Session::Cookie

  get '/' do
    redirect '/auth/twitter'
  end


  get '/auth/twitter/callback' do 
    session[:token] = env['omniauth.auth']['credentials'].token
    session[:secret] = env['omniauth.auth']['credentials'].secret
    #MultiJson.encode(request.env)

    #binding.pry
    redirect '/loggedin'
  end

  get '/loggedin' do
    @info_user = client.user("secuip").to_hash
    @colleccion = collec
    binding.pry
  end





helpers do
  
  def client
    @client ||= Twitter::Client.new  :oauth_token => session[:token],
                                    :oauth_token_secret => session[:secret]  
  end

  def bdd
    @instance ||= Mongo::Connection.new('localhost', 27017).db('twitter_test')
  end

  def collec
    @db = bdd['tweetcol']
  end

end



end

