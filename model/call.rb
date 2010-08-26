class Call < Sequel::Model
  def self.create_from_xml(xml)

    # convert to JSON and store in CouchDB
    log = Log.create_from_xml(xml)

    # Store basic data in a postgres record
    create(
      :couch_id           => log._id,
      :username           => log.callflow["caller_profile"]["username"],
      :caller_id_number   => log.callflow["caller_profile"]["caller_id_number"],
      :caller_id_name     => log.callflow["caller_profile"]["caller_id_name"],
      :destination_number => log.callflow["caller_profile"]["destination_number"],
      :channel            => log.callflow["caller_profile"]["chan_name"],
      :context            => log.callflow["caller_profile"]["context"],
      :start_stamp        => Time.at(log.variables["start_epoch"]),
      :end_stamp          => Time.at(log.variables["end_epoch"]),
      :duration           => log.variables["duration"],
      :billsec            => log.variables["billsec"],
    )

  end

  def detail
    Log[couch_id] if couch_id
  end
end
