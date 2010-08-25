class MainController < Controller
  layout :main
  helper :xhtml
  engine :Erubis

  # the index action is called automatically when no other action is specified
  def index
    @calls = Call.all
    @title = "TinyCDR - FreeSWITCH CDR Reporting"
  end

  def user_report
    username, phone_num = request[:username, :phone_num].map{|s| s.to_s.strip }
    username = nil if username.empty?
    phone_num = nil if phone_num.empty?

    conditionals = 'username = ? or caller_id_number = ? or destination_number = ?'

    filter =
      if username && phone_num
        [ "(#{conditionals}) and (#{conditionals})",
          username, username, username,
          phone_num, phone_num, phone_num ]
      elsif username
        [conditionals, username, username, username]
      elsif phone_num
        [conditionals, phone_num, phone_num, phone_num]
      end

    @calls = filter ? Call.filter(filter) : Call.all
    @title = "TinyCDR - FreeSWITCH CDR Reporting"
  end
end
