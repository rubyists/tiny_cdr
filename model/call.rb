class Call < Sequel::Model
  def self.create_from_xml(xml)
    doc = Nokogiri::XML(xml)

    create(
      :username           => doc.at('/cdr/callflow/caller_profile/username').to_s,
      :caller_id_number   => doc.at('/cdr/callflow/caller_profile/caller_id_number').to_s,
      :caller_id_name     => doc.at('/cdr/callflow/caller_profile/caller_id_name').to_s,
      :destination_number => doc.at('/cdr/callflow/caller_profile/destination_number').to_s,
      :channel            => doc.at('/cdr/callflow/caller_profile/chan_name').to_s,
      :context            => doc.at('/cdr/callflow/caller_profile/context').to_s,
      :start_stamp        => Time.at(doc.at('/cdr/variables/start_epoch').to_i),
      :end_stamp          => Time.at(doc.at('/cdr/variables/end_epoch').to_i),
      :duration           => doc.at('/cdr/variables/duration').to_i,
      :billsec            => doc.at('/cdr/variables/billsec').to_i,
    )

    # convert to JSON and store in CouchDB
    CDR_LOG_PARSER.parse(xml)
  end
end
