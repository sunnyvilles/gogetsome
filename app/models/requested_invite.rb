class RequestedInvite < ActiveRecord::Base
  require 'digest/md5'

#  validates :email, :presence => true#, {:message => "Email Can't be blank"}
#  validates :email, :uniqueness => {:message => "This Email is already been registered. Please try another email" }
#  validates :email, :format => {:with => /^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6}$/,
#                                :message => "Please enter valid Email Address"}


  #TODO :: User geo location info to be stored in this table
  #TODO :: retry code in this method has to be tested
  def self.add_request_invite(params)
    return {:err => "err1"} if params[:email].blank?
    return {:err => "err2"} unless /^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6}$/.match(params[:email])
    requested_invite, attempts = nil, 0
    begin
      subscription_code = encrypt(params[:email], Time.now.to_i.to_s)
      requested_invite = create(:email => params[:email], :ip_address => params[:ip_address], :city => "pune", :state => "state", :country => "country",
              :zipcode => "zip", :subscription_code => subscription_code, :invite_code => gen_invite_code(6))
    rescue Exception => e
      puts "-----e-----#{e.inspect}"
      if /Mysql2::Error: Duplicate entry/.match(e.to_s)
        return {:err => "err3"} if e.to_s.index("email")
        retry if e.index("subscription_code") || e.to_s.index("invite_code") and attempts < 3
      else
        return {:err => "err4"}
      end
    end

#
#    attempts = 0
#    begin
#      make_service_call()
#    rescue Exception
#      attempts += 1
#      retry unless attempts > 2
#      exit -1
#    ensure
#      puts "ensure! #{attempts}"
#    end


    
    return {:err => nil, :requested_invite => requested_invite}
  end

  protected

  def self.encrypt(str1, str2)
    Digest::MD5.hexdigest(str1+str2)
  end
  
  # Generate invitation code
  def self.gen_invite_code(len)
    chars = ("a".."z").to_a+("0".."9").to_a
    invite_code = ""
    1.upto(len) { |i| invite_code << chars[rand(chars.size-1)] }
    return invite_code
  end
  
end
