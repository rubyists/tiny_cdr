class CdrController < Controller
  def post
    call = TinyCdr::Call.create_from_xml(request['cdr'])
    puts "New call from #{call.username} to #{call.destination_number}"
  end
end
