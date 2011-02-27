class CdrController < Controller
  def post
    uuid, xml = request['uuid', 'cdr']
    Ramaze::Log.info xml[0, 9]
    xml = CGI.unescape(xml) if xml[0, 9] == '%3C%3Fxml'
    call = TinyCdr::Call.create_from_xml(uuid, xml)
    Ramaze::Log.info "New call from #{call.username} to #{call.destination_number}"
  end
end
