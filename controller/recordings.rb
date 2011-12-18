module TinyCdr
  class RecordingsController < Controller
    map '/recordings'
    layout :recordings
    helper :xhtml, :send_file
    engine :Etanni

    def index
      @calls = TinyCdr::Call.filter(
        'billsec > 120'
      ).filter(
        "(xpath('/cdr/variables/call_record_path'::text, original))[1] is not null"
      ).limit(20)
    end

    def listen(format, id)
      if call = TinyCdr::Call[id: id]
        if File.file?(call.recording_path)
          send_file(call.recording_path, 'audio/x-wav; charset=binary')
        end
      end

      respond 'Not Found', 404
    end

    private

    def format_time(time)
      time.strftime('%Y-%m-%d %H:%M')
    end
  end
end
