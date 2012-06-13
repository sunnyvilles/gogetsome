class Web::UsersController < ApplicationController
  
  def twitter_connect
    client = TwitterOAuth::Client.new(
        :consumer_key => 'WS8hAKtAxKcvEx216Z9QA',
        :consumer_secret => 'jYDHMkFsLIIF3Y3eJ2SPOPezbQ4O996lXWlIQ8cc')

    request_token = client.request_token(:oauth_callback => "http://127.0.0.1:3000/twitter-cb") #"http://172.29.145.65:3000/twitter-cb"

    redirect_to request_token.authorize_url
  end

  def twitter_callback
    puts "-------params------#{params.inspect}"
    redirect_to "/"
  end
end
