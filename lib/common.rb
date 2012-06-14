class Common

  def self.twitter_handler
    client = TwitterOAuth::Client.new(
      :consumer_key => GlobalConstant::TWITTER_CONFIG['consumer_key'],
        :consumer_secret => GlobalConstant::TWITTER_CONFIG['consumer_secret_key'])

    return client
  end
end