module TinyCdr
  class Call < Sequel::Model
    set_dataset TinyCdr.db[:calls]
    def self.create_from_xml(uuid, xml, leg = nil)

      if uuid[0,2] == 'a_'
        leg = 'a' 
        uuid = uuid[2..-1]
      end
      # convert to JSON and store in CouchDB
      log = TinyCdr::Log.find_or_create_from_xml(uuid, xml)

      unless self.find(:couch_id => log._id)
        # Store basic data in a postgres record, or send a new one if it's a b_leg
        call = {
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
        }
        if leg == 'a'
          create call
        else
          new call
        end
      end

    end

    # @start - must be %m/%d/%Y
    # @stop - must be %m/%d/%Y
    # @avoid_locals - true if you don't want to see ext to ext calls
    # @conditions - may include :username or :phone
    def self.user_report(start, stop, conditions = {})
      conditionals = 'username in ? or caller_id_number in ? or destination_number in ?'
      username = conditions[:username]
      phone_num = conditions[:phone]
      avoid_locals = conditions.keys.include?(:avoid_locals) ? conditions[:avoid_locals] : false # default to false
      queue_only = conditions.keys.include?(:queue_only) ? conditions[:queue_only] : false # default to false
      locals_only = conditions.keys.include?(:locals_only) ? conditions[:locals_only] : false # default to false
      usernames = username.split(",") rescue []
      phone_nums = phone_num.split(",") rescue []
      filters = if usernames.size > 0
        if phone_nums.size > 0
          ["(#{conditionals}) and (#{conditionals})", usernames, usernames, usernames, phone_nums, phone_nums, phone_nums]
        else
          ["(#{conditionals})", usernames, usernames, usernames]
        end
      elsif phone_nums.size > 0
        ["(#{conditionals})", phone_nums, phone_nums, phone_nums]
      end
      ds = (filters ? TinyCdr::Call.filter(filters) : TinyCdr::Call)
      unless start.nil?
        start.kind_of?(Date) ?  (ds = ds.filter { start_stamp >= start }) : (ds = ds.filter{start_stamp >= Date.strptime(start, "%m/%d/%Y") })
      end
      unless stop.nil?
        stop.kind_of?(Date) ? (ds = ds.filter {end_stamp <= stop }) : (ds = ds.filter{end_stamp <= Date.strptime(stop, "%m/%d/%Y") })
      end
      ds = ds.filter("caller_id_number ~ '^\\d\\d\\d\\d\\d+$' or destination_number ~ '^\\d\\d\\d\\d\\d+$'") if avoid_locals
      ds = ds.filter("caller_id_number ~ '^\\d\\d\\d\\d$' and destination_number ~ '^\\d\\d\\d\\d$'") if locals_only
      ds = ds.filter("channel ~ '192.168.6.118$' or channel ~ '192.168.6.37$'") if queue_only
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
