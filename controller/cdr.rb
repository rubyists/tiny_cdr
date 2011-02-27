class CdrController < Controller
  def post
    uuid, xml, leg = request['uuid', 'cdr', 'leg']
    Ramaze::Log.info xml[0, 9]
    xml = CGI.unescape(xml) if xml[0, 9] == '%3C%3Fxml'
    call = TinyCdr::Call.create_from_xml(uuid, leg, xml)
    Ramaze::Log.info "New call from #{call.username || call.caller_id_number} to #{call.destination_number}"
  end
end
