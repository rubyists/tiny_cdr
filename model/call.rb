require "fileutils"
module TinyCdr
  class Call < Sequel::Model
    set_dataset TinyCdr.db[:calls]
    plugin :lazy_attributes, :original

    def inspect
      "<##{self.class.name} #{values.reject { |k,v| k.to_s == "original" }}>"
    end

    # TODO: Make these both options
    RECORD_PATH_PREFIX_FROM = "recordings"
    BASE_RECORD_PATH = TinyCdr.options[:base_record_path]
    ARCHIVE_PATHS = TinyCdr.options[:archive_record_paths].split(":")
    TMP_FILE_PATH = TinyCdr.options[:tmp_file_path]

    def convert_wav(type, curfile = nil)
      curfile ||= recording_path
      tmp_file_name = "#{File.basename(curfile)}.#{type}"
      tmp_file_path = File.join(TMP_FILE_PATH, tmp_file_name)
      cmd = case type
      when "mp3"
        'lame -V 2 %s %s' % [curfile, tmp_file_path]
      when "ogg"
        'oggenc -o %s %s' % [tmp_file_path, curfile]
      end
      return nil unless cmd
      output = %x{#{cmd} 2>&1}
      retval = $?
      if retval == 0
        tmp_file_path
      else
        Log.error "Conversion of #{curfile} to #{type} failed: #{retval} -> #{output}"
        nil
      end
    end

    def convert_spx(type)
      tmp_file_name = "#{File.basename(recording_path)}.#{type}"
      wav_file = File.join(TMP_FILE_PATH, tmp_file_name)
      output = %x{speexdec #{recording_path} #{wav_file} 2>&1}
      retval = $?
      if $? == 0
        return wav_file if type == "wav"
        new_file = convert_wav(type, wav_file)
        FileUtils.rm wav_file
        new_file
      else
        Log.error "Conversion of #{recording_path} to wav failed: #{retval} -> #{output}"
        nil
      end
    end

    def convert_recording(current_type, new_type)
      case current_type
      when "wav"
        convert_wav new_type
      when "spx"
        convert_spx new_type
      end
    end

    def current_format
      return nil unless recording_path
      recording_path.reverse.split(".", 2).first.reverse
    end

    def format_recording(type)
      return nil unless recording_path
      current_type = current_format
      return recording_path if type == current_type
      convert_recording(current_type, type)
    end

    def recording_path # where the file lives on _this_ filesystem
      unless recording.nil?
        return recording if File.exists?(recording)
      end
      # turns /var/lib/freeswitch/recordings/directory/file.wav into
      # ENV['HOME'] + "/tiny_cdr_files/directory/file.wav"
      return nil if call_record_path.empty?
      original_location = File.join(BASE_RECORD_PATH, call_record_path.sub(%r{^.*/#{RECORD_PATH_PREFIX_FROM}/}, ''))
      if File.exists? original_location
        self.recording = original_location
        self.save
        return self.recording
      else 
        found_record = nil
        paths = [BASE_RECORD_PATH] + ARCHIVE_PATHS
        base_file = File.basename(original_location)
        record_found = paths.find do |path|
          found = Dir[File.join(path, "**", "#{CGI.unescape(base_file)}*")]
          if found.count == 1
            found_record = found.first
            true
          else
            false
          end
        end
        if record_found
          self.recording = found_record
          self.save
          return self.recording
        else
          return nil
        end
      end
    end

    def call_record_path # raw file path
      if node = xml.xpath('/cdr/variables/call_record_path')
        node.text
      else
        nil
      end
    end

    def xml
      @_xml ||= Nokogiri::XML(original)
    end

    def detail
      @_detail ||= xml.to_xml(indent: 2)
    end

    def fifo_recipient
      detail.callflow["caller_profile"]["originatee"]["originatee_caller_profile"]["destination_number"] rescue nil
    end

    def self.create_from_xml(given_uuid, xml, ignored_leg = nil)
      /^(?<leg>a|b)_(?<uuid>\S+)$/ =~ given_uuid

      if existing = self[uuid: uuid]
        return existing
      end

      log = Nokogiri::XML(xml)

      call = create(
        leg:                 leg,
        uuid:                uuid,
        username:            log.at('/cdr/callflow/caller_profile/username').text,
        caller_id_number:    log.at('/cdr/callflow/caller_profile/caller_id_number').text,
        caller_id_name:      (log.at('/cdr/callflow/caller_profile/origination/origination_caller_profile/caller_id_name') || log.at('/cdr/callflow/caller_profile/caller_id_name')).text,
        destination_number:  log.at('/cdr/callflow/caller_profile/destination_number').text,
        channel:             log.at('/cdr/callflow/caller_profile/chan_name').text,
        context:             log.at('/cdr/callflow/caller_profile/context').text,
        start_stamp: Time.at(log.at('/cdr/variables/start_epoch').text.to_i),
        end_stamp:   Time.at(log.at('/cdr/variables/end_epoch').text.to_i),
        billsec:             log.at('/cdr/variables/billsec').text,
        duration:            log.at('/cdr/variables/duration').text,
        original:            log.to_xml(indent: 2),
      )
      call.recording_path
      call
    end

    def queue_servers
      return @queue_servers if @queue_servers
      if q_servers = TinyCdr.options[:queue_servers]
        @queue_servers = q_servers.split(",")
      else
        @queue_servers = []
      end
    end

    def can_listen?(user = nil)
      if user
        if manager = user.manager
          manager.can_listen?(self)
        else
          caller_id_number == user.extension || destination_number == user.extension || username == user.extension
        end
      else
        true
      end
    end
    # @start - must be %m/%d/%Y
    # @stop - must be %m/%d/%Y
    # @avoid_locals - true if you don't want to see ext to ext calls
    # @conditions - may include :username or :phone
    def self.user_report(start = nil, stop = nil, user = nil, conditions = {})
      conditionals = 'username in ? or caller_id_number in ? or destination_number in ?'
      conditional = 'caller_id_number ~ ? or destination_number ~ ?'
      username = conditions[:username]
      phone_num = conditions[:phone]
      avoid_locals = conditions.keys.include?(:avoid_locals) ? conditions[:avoid_locals] : false # default to false
      queue_only = conditions.keys.include?(:queue_only) ? conditions[:queue_only] : false # default to false
      locals_only = conditions.keys.include?(:locals_only) ? conditions[:locals_only] : false # default to false
      usernames = username.split(",") rescue []
      phone_nums = phone_num.split(",") rescue []
      filters = if usernames.size > 0
        if phone_nums.size > 0
          ["(#{conditionals}) and (#{conditional})", *([usernames] * 3), *([phone_nums.join('|')] * 2)]
        else
          ["#{conditionals}", *([usernames] * 3)]
        end
      elsif phone_nums.size > 0
        ["#{conditional}", *([phone_nums.join("|")] * 2)]
      end
      ds = (filters ? TinyCdr::Call.filter(filters) : TinyCdr::Call)
      if user
        if user.manager
          ds = user.manager.filter_calls(ds)
        else
          ds = ds.filter("username = ? or destination_number = ? or caller_id_number = ?", *([user.extension] * 3))
        end
      else
        ds.order(:start_stamp)
      end
      if queue_only
        queue_conditions = []
        queue_servers.each do |queue_server|
          queue_condidtions << "channel ~ '#{queue_server}'"
        end
        ds = ds.filter(queue_conditions.join(" or ")) if queue_conditions.count > 0
      end
      unless start.nil?
        start.kind_of?(Date) ?  (ds = ds.filter { start_stamp >= start }) : (ds = ds.filter{start_stamp >= Date.strptime(start, "%m/%d/%Y") })
      end
      unless stop.nil?
        stop.kind_of?(Date) ? (ds = ds.filter {end_stamp <= stop }) : (ds = ds.filter{end_stamp <= Date.strptime(stop, "%m/%d/%Y") })
      end
      ds = ds.filter("caller_id_number ~ '^\\d\\d\\d\\d\\d+$' or destination_number ~ '^\\d\\d\\d\\d\\d+$'") if avoid_locals
      ds = ds.filter("caller_id_number ~ '^\\d\\d\\d\\d?$' and destination_number ~ '^\\d\\d\\d\\d?$'") if locals_only
      ds.order(:start_stamp)
    end
  end
end
