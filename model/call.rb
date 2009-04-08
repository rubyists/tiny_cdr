require 'rexml/document'

class Call < Sequel::Model

  def self.create_from_xml(doc)
    self.create(:username => doc.username, :caller_id_number => doc.caller_id_number, :caller_id_name => doc.caller_id_name, :destination_number => doc.destination_number, :channel => doc.channel, :context => doc.context, :start_stamp => Time.at(doc.start_stamp.to_f), :end_stamp => Time.at(doc.end_stamp.to_f), :duration => doc.duration, :billsec => doc.billsec)
  end

end
