class Web::UsersController < ApplicationController
  
  def twitter_connect
    client = TwitterOAuth::Client.new(
        :consumer_key => 'WS8hAKtAxKcvEx216Z9QA',
        :consumer_secret => 'jYDHMkFsLIIF3Y3eJ2SPOPezbQ4O996lXWlIQ8cc')

    request_token = client.request_token(:oauth_callback => "http://127.0.0.1:3000/twitter-cb")
    puts "-----request_token----#{request_token.inspect}"
    redirect_to request_token.authorize_url.to_s.sub("authorize","authenticate")
  end

  def twitter_callback

    client = TwitterOAuth::Client.new(
        :consumer_key => 'WS8hAKtAxKcvEx216Z9QA',
        :consumer_secret => 'jYDHMkFsLIIF3Y3eJ2SPOPezbQ4O996lXWlIQ8cc')

    client.request_token(:oauth_callback => "http://127.0.0.1:3000/twitter-cb")
    
    client.authorize(
      params[:oauth_token],
      'jYDHMkFsLIIF3Y3eJ2SPOPezbQ4O996lXWlIQ8cc',
      :oauth_verifier => params[:oauth_verifier]
    )
    puts "------t/f------#{client.authorized?}----client-----#{client.inspect}-----#{client.info.inspect}"
    redirect_to "/"
  end
end
