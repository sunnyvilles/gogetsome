class RequestedInvite < ActiveRecord::Base
  validates :email, :presence => true
  validates :email, :uniqueness => {:message => "This Email is already been registered. Please try another email" }
  validates :email, :format => {:with => /^(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6}$/,
                                :message => "Please enter valid Email Address"}

  def self.add_request_invite(params)
    puts "-----params----#{params.inspect}"
    error_msg = create(:email => params[:email], :ip_address => params[:ip_address]).errors[:email]
    if error_msg.length > 0
      return {:err_msg => error_msg, :invitation_code => nil}
    else
      
      # Random invite code of 6 characters
      invitation_code = gen_invite_code(6)
    end

    return {:err_msg => "", :invitation_code => invitation_code}
    
  end

  # Generate invitation code
  def self.gen_invite_code(len)
    chars = ("a".."z").to_a+("0".."9").to_a
    invite_code = ""
    1.upto(len) { |i| invite_code << chars[rand(chars.size-1)] }
    return invite_code
  end

  
end
