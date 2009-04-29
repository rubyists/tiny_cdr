# Default url mappings are:
#  a controller called Main is mapped on the root of the site: /
#  a controller called Something is mapped on: /something
# If you want to override this, add a line like this inside the class
#  map '/otherurl'
# this will force the controller to be mounted on: /otherurl

class MainController < Controller
  layout '/layout/main'
  helper :xhtml
  engine :Erubis

  # the index action is called automatically when no other action is specified
  def index
    @calls = Call.all
    @title = "TinyCDR - FreeSWITCH CDR Reporting"
  end

  def user_report
    puts request
    username, phone_num = request["username"], request["phone_num"]
    filter = false
    conditionals = 'username = ? or caller_id_number = ? or destination_number = ?'
    # Search by username and phone number
    filter = ["(#{conditionals}) and (#{conditionals})", username, username, username, phone_num, phone_num, phone_num] unless username.empty? or phone_num.empty? or username.nil? or phone_num.nil?
    # Search by username only
    filter = [conditionals, username, username, username] unless username.empty? or username.nil? 
    # Search by phone number only
    filter = [conditionals, phone_num, phone_num, phone_num] unless phone_num.empty? or phone_num.nil?
    if filter
      @calls = Call.filter(filter)
    else
      @calls = Call.all
    end
    @title = "TinyCDR - FreeSWITCH CDR Reporting"
  end

  # the string returned at the end of the function is used as the html body
  # if there is no template for the action. if there is a template, the string
  # is silently ignored
  def notemplate
    "there is no 'notemplate.xhtml' associated with this action"
  end

  private

  def make_filter

  end

end
