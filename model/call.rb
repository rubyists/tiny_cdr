class Call < Sequel::Model
  def self.create_from_xml(xml)

    # convert to JSON and store in CouchDB
    log = Log.create_from_xml(xml)

    # Store basic data in a postgres record
    doc = Nokogiri::XML(xml)

    create(
      :couch_id           => log._id,
      :username           => doc.at('/cdr/callflow/caller_profile/username').inner_text,
      :caller_id_number   => doc.at('/cdr/callflow/caller_profile/caller_id_number').inner_text,
      :caller_id_name     => doc.at('/cdr/callflow/caller_profile/caller_id_name').inner_text,
      :destination_number => doc.at('/cdr/callflow/caller_profile/destination_number').inner_text,
      :channel            => doc.at('/cdr/callflow/caller_profile/chan_name').inner_text,
      :context            => doc.at('/cdr/callflow/caller_profile/context').inner_text,
      :start_stamp        => Time.at(doc.at('/cdr/variables/start_epoch').inner_text.to_i),
      :end_stamp          => Time.at(doc.at('/cdr/variables/end_epoch').inner_text.to_i),
      :duration           => doc.at('/cdr/variables/duration').inner_text.to_i,
      :billsec            => doc.at('/cdr/variables/billsec').inner_text.to_i,
    )

  end
end
