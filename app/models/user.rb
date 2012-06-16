class User < ActiveRecord::Base

  def self.create_user(params)
    params[:ip_address] = "127.0.0.1"
    return {:err => "err1", :err_msg => "No Subscription with this email", :user => nil} if params[:subscription_code].blank?
    #return {:err => "err2", :err_msg => "Password was blank", :user => nil} if params[:password].blank? || params[:password_confirmation].blank?
    return {:err => "err3", :err_msg => "Both passwords are not same", :user => nil} if params[:password] != params[:password_confirmation]

    puts "----params[:terms_conditions].to_s---#{params[:terms_conditions].to_s != "on"}-----#{params[:terms_conditions].to_s}"
    return {:err => "err4", :err_msg => "Please accept the terms and conditions", :user => nil} if params[:terms_conditions].to_s != "on"
    requested_invite_info = RequestedInvite.where(:subscription_code => params[:subscription_code]).first
    return {:err => "err5", :err_msg => "We diddn't find any subscription with this email", :user => nil} if requested_invite_info.nil?
    return {:err => "err6", :err_msg => "This email was already subscripbed", :user => nil} if requested_invite_info.signedup_at.present?

    begin
      user = User.create(:email => requested_invite_info.email, :auth => requested_invite_info.subscription_code, :requested_invites => requested_invite_info.requested_invites,
                         :subscribed_users => requested_invite_info.subscribed_users, :invite_code => requested_invite_info.invite_code) #rescue nil
    rescue Exception => e
      puts "-----e-----#{e.inspect}"
      if /Mysql2::Error: Duplicate entry/.match(e.to_s)
        return {:err => "err3", :err_msg => "This email was already subscripbed"} if e.index("email")
        retry if e.index("subscription_code") || e.index("invite_code") and attempts < 3
      else
        return {:err => "err4", :err_msg => "Something went wrong. Please try later"}
      end
    end
    return {:err => nil, :user => user}

  end
end
