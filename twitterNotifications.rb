require 'bundler/setup'
require 'sinatra'
require 'twitter'
require 'omniauth-twitter'
require 'pry'
require 'mongo'
require 'tweetstream'
require 'json'


class TwitterNotifications < Sinatra::Base

  set :views, 'views'
  enable :sessions
  use Rack::Session::Cookie

  APP_TOKEN   = 'qSXgYnfl9TQHL0rcRw'
  APP_SECRET  = 'zhzEDv12a87RimkvaisEi5IZvqISzEVmf2gDIJQCuw'

  Twitter.configure do |config|
    config.consumer_key     = APP_TOKEN
    config.consumer_secret  = APP_SECRET
  end

  use OmniAuth::Builder do 
    provider :twitter, APP_TOKEN, APP_SECRET
  end


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

    puts "Ja ANDA !!!"
    @colleccion = createCollec
    @stream = clientStream
    #data = getTweeterInfos "glsignal"
    
    #@colleccion.insert(data)

    #@escibirMuro = postToTwitter 'hola3'

    #@chupaTweet = stockListenedStream
    
    #@tracked = stockTrackedStream 'EnHalloweenMeVoyaDisfrazarDe'

    #@follow = followAlguien "aramosf"

    binding.pry

  end



helpers do
  
  def client
    @client ||= Twitter::Client.new  :oauth_token => session[:token],
                                    :oauth_token_secret => session[:secret]  
  end

  def clientStream
    TweetStream.configure do |config|
      config.consumer_key       = APP_TOKEN
      config.consumer_secret    = APP_SECRET
      config.oauth_token        = session[:token]
      config.oauth_token_secret = session[:secret]
      config.auth_method        = :oauth
    end
      @clientStream ||= TweetStream::Client.new
  end

  def bdd
    @instance ||= Mongo::Connection.new('localhost', 27017).db('twitter_test')
  end

  def createCollec
    @db ||= bdd['tweetcol']
    #@db = bdd.collection('tweetcol')
  end

  def getTweeterInfos user_id
    @info_user = client.user(user_id).to_hash
  end

  def postToTwitter message
    @tweetear = client.update(message)
  end


  def stockListenedStream
    @stream = clientStream
    @stream.userstream do |tweets| 
      @colleccion.insert(tweets.to_hash) 
    end
  end  

  def stockTrackedStream hashTag
    @stream = clientStream
    @stream.track(hashTag) do |htagsTweets| 
      @colleccion.insert(htagsTweets.to_hash) 
    end
  end

  def followStreamOfPeople user_id
    @stream = clientStream
    @stream.follow(user_id) do |follow|
      @colleccion.insert(follow.to_hash)
    end
  end

end



end

