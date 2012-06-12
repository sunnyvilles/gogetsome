class Web::UsersController < ApplicationController
  def twitter_connect
    client = TwitterOAuth::Client.new(
        :consumer_key => GlobalConstant::FACEBOOK_CONFIG,
        :consumer_secret => GlobalConstant::FACEBOOK_CONFIG
    )

    request_token = client.request_token(:oauth_callback => "http://google.com") #"http://172.29.145.65:3000/twitter-cb"
#:oauth_callback required for web apps, since oauth gem by default force PIN-based flow
#( see http://groups.google.com/group/twitter-development-talk/browse_thread/thread/472500cfe9e7cdb9/848f834227d3e64d )

puts request_token.authorize_url
#=> http://twitter.com/oauth/authorize?oauth_token=TOKEN
#Link this url to in your view file, so that user will be redirected to the Twitter authentication page.

    #redirect_to ""
    render :nothing
  end
end
