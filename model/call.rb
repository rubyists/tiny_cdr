module TinyCdr
  class Call < Sequel::Model
    set_dataset TinyCdr.db[:calls]
    def self.create_from_xml(xml)

      # convert to JSON and store in CouchDB
      log = TinyCdr::Log.find_or_create_from_xml(xml)

      unless self.find(:couch_id => log._id)
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
          :billsec            => log.variables["billsec"]
        )
      end

    end

    # @start - must be %m/%d/%Y
    # @stop - must be %m/%d/%Y
    # @avoid_locals - true if you don't want to see ext to ext calls
    # @conditions - may include :username or :phone
    def self.user_report(start, stop, conditions = {})
      conditionals = 'username = ? or caller_id_number = ? or destination_number = ?'
      username = conditions[:username]
      phone_num = conditions[:phone]
      avoid_locals = conditions.keys.include?(:avoid_locals) ? conditions[:avoid_locals] : true
      filters =
        if username && phone_num
          [ "(#{conditionals}) and (#{conditionals})",
            username, username, username,
            phone_num, phone_num, phone_num ]
        elsif username
          [conditionals, username, username, username]
        elsif phone_num
          [conditionals, phone_num, phone_num, phone_num]
        end
      ds = (filters ? TinyCdr::Call.filter(filters) : TinyCdr::Call)
      ds = ds.filter{start_stamp >= Date.strptime(start, "%m/%d/%Y") } if !(start.nil? or start.empty?)
      ds = ds.filter{end_stamp <= Date.strptime(stop, "%m/%d/%Y") } if !(stop.nil? or stop.empty?)
      ds = ds.filter("caller_id_number ~ '^\\d\\d\\d\\d\\d+$' or destination_number ~ '^\\d\\d\\d\\d\\d+$'") if avoid_locals
      ds.order(:start_stamp)
    end

    def uuid
      detail.callflow["caller_profile"]["uuid"]
    end
    def detail
      @_couch ||= Log[couch_id] if couch_id
    end

    def fifo_recipient
      detail.callflow["caller_profile"]["originatee"]["originatee_caller_profile"]["destination_number"] rescue nil
    end
  end
end
