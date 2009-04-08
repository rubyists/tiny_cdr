# Default url mappings are:
#  a controller called Main is mapped on the root of the site: /
#  a controller called Something is mapped on: /something
# If you want to override this, add a line like this inside the class
#  map '/otherurl'
# this will force the controller to be mounted on: /otherurl

class CdrController < Controller

  def post
    doc = TinyCDR::ScrubXML.new request['cdr']
    call = Call.create_from_xml(doc) 
    puts "New call from #{call.username} to #{call.destination_number}"
  end

end
