class Web::UsersController < ApplicationController
  
  def twitter_connect

    request_token = Common.twitter_handler.request_token(:oauth_callback => "http://127.0.0.1:3000/twitter-cb")
    puts "-----request_token----#{request_token.inspect}"
    redirect_to request_token.authorize_url.to_s.sub("authorize","authenticate")
  end

  def twitter_callback

    client = Common.twitter_handler

    client.request_token(:oauth_callback => "http://127.0.0.1:3000/twitter-cb")
    
    client.authorize(
      params[:oauth_token],
      'jYDHMkFsLIIF3Y3eJ2SPOPezbQ4O996lXWlIQ8cc',
      :oauth_verifier => params[:oauth_verifier]
    )
    puts "------t/f------#{client.authorized?}----client-----#{client.inspect}-----#{client.info.inspect}"
    redirect_to "/"
  end

  def request_invite
    result = RequestedInvite.add_request_invite(:email => params[:email], :ip_address => request.remote_ip)
    puts "----result-----#{result.inspect}"
     UserMailer.welcome_email(result[:requested_invite]).deliver if result[:err].blank?
    render :json => result
  end

  def invite
    render :json => "Success"
  end

  def subscribe
    @requested_invite_info = RequestedInvite.where(:subscription_code => params[:subscription_code]).first
    @dont_show = true if @requested_invite_info.blank?
  end

  def create_user
    puts "---p1--#{params.inspect}"
    result = User.create_user(params)
    puts "------result------#{result.inspect}"
    
    if result[:err_msg].present?
      flash[:error] = result[:err_msg]
      render :action => 'subscribe' and return
    end
    redirect_to "/"
  end

end