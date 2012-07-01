class Common
  @@logger = ActiveRecord::Base.logger
  
  def self.twitter_handler
    client = TwitterOAuth::Client.new(
      :consumer_key => GlobalConstant::TWITTER_CONFIG['consumer_key'],
        :consumer_secret => GlobalConstant::TWITTER_CONFIG['consumer_secret_key'])

    return client
  end

  # BELOW methods are used in application, calls set, get or clear functions of memcahced.
  # Set memcached key
  #
  # <b>Excepts</b>
  # * <b>key</b> <em>(String)</em> - memcache key name.
  # * <b>data</b> <em>(Object/String/Integer)</em> - data need to be stored in memcached
  # * <b>time_of_cache</b> <em>(Integer)</em> - memcache key expiry time in seconds
  # * <b>marshaling</b> <em>(Enum)</em> - Marshal data or not?
  #
  def self.set_memcached(key, data, time_of_cache, marshaling)
    Timeout::timeout(1) {
      GlobalConstant::MemcachedObject.set(Digest::MD5.hexdigest(key), data, time_of_cache, marshaling)
      return nil
    }
    rescue Exception => exc
    @@logger.error "MEMCACHE-ERROR:" + exc.message
    return nil
  end

  # Get memcached key
  #
  # <b>Excepts</b>
  # * params[:key] <em>(String)</em> - memcache key name.
  # * params[:marshaling] <em>(Enum)</em> - Marshal data or not?
  #
  def self.get_memcached(key, marshaling)
    Timeout::timeout(1) {
      return GlobalConstant::MemcachedObject.get(Digest::MD5.hexdigest(key), marshaling)
    }
    rescue Exception => exc
    @@logger.error "MEMCACHE-ERROR:" + exc.message if exc.class.to_s != "Memcached::NotFound"
    return nil
 end

  # Delete memcached key
  #
  # <b>Excepts</b>
  # * params[:key] <em>(String)</em> - memcache key name.
  #
  def self.delete_memcached(key)
    Timeout::timeout(1) {
      GlobalConstant::MemcachedObject.delete(Digest::MD5.hexdigest(key))
      return nil
    }
    rescue Exception => exc
    @@logger.error "MEMCACHE-ERROR:" + exc.message if exc.class.to_s != "Memcached::NotFound"
    return nil
  end
end