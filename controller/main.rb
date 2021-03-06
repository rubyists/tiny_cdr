require 'date'
require File.dirname(__FILE__) + '/../lib/daily_good_abandon_report_by_hour.rb'
class MainController < Controller
  helper :send_file

  def login
    @title = "Login"
    @head  = '<script type="text/javascript" src="/js/login.js"></script>'
    redirect_referer if logged_in?
    return unless request.post?
    user_login(request.subset(:login, :password))
    answer :/
  end

  def logout
    @title = "Logged Out"
    user_logout 
    @flash = 'You are now logged out. <a href="/login">Log Back In</a>'
  end

  # the index action is called automatically when no other action is specified
  def index
    redirect :search
  end

  def search
    login_first
    @title = "TinyCDR - FreeSWITCH CDR Reporting"
  end

  def give_file
    login_first
    filename = request[:filename]   
    render_file(filename,:content_type => "application/excel" )
  end

  def inbound_stats
    login_first
    start = request[:argdate]
    @title = "Hourly Incoming Dropped Call Report"
    @title << " for #{start}" unless start.nil?
    fstr = (Date.strptime(start,"%m/%d/%Y")||Date.today).strftime("%Y%m%d")
    @filename = "/tmp/InboundHourly#{fstr}.csv"
    @tempfilename = "tmp/cancelled_callids.html"
    rep = DailyGoodAbandonReportByHour.new(:argdate => start)    
    @calls = rep.create_report(@filename)
  end

  def user_report
    login_first
    start, stop = request[:date_start, :date_end]
    start = nil if start.empty?
    stop = nil if stop.empty?
    username, phone_number = request[:username, :phone_number].map{|s| s.to_s.strip }
    username = nil if username.empty?
    phone_number = nil if phone_number.empty?
    @title = "Call Detail"
    @title << " for #{username}" unless username.nil?
    @title << " to #{phone_number}" unless phone_number.nil?
    @title << " from #{start.to_s.gsub('/','-')}" unless start.nil?
    @title << " until #{stop.to_s.gsub('/','-')}" unless stop.nil?
    queue_only = (request[:queue_only].empty? ? false : true) rescue nil
    avoid_locals = (request[:avoid_locals].empty? ? false : true) rescue nil
    locals_only = (request[:locals_only].empty? ? false : true) rescue nil
    Ramaze::Log.debug("Calling user report for #{user.inspect} with params phone: #{phone_number} username: #{username} start: #{start} stop: #{stop}")
    ds = TinyCdr::Call.user_report(start, stop, user, {:username => username,
                                                 :phone    => phone_number,
                                                 :queue_only    => queue_only,
                                                 :locals_only    => locals_only,
                                                 :avoid_locals => avoid_locals})
    @size = ds.count
    @call_array = ds.map { |call| call_array(call) }
    @total_time = ds.inject(0) {|a,b| a + b.duration.to_i }/60
  end

  def listen(fname)
    login_first
    require "cgi"
    format, id = fname.reverse.split(".", 2).map { |n| n.reverse }
    if call = TinyCdr::Call[id: id]
      if call.can_listen?(user)
        if call.recording_path.nil?
          Ramaze::Log.error "Call #{id} #{call.recording_path} not available"
          respond 'Not Found', 404
        else
          mime_type = case format
                      when "ogg"
                        "ogg"
                      when "wav"
                        "x-wav"
                      when "mp3"
                        "x-mpeg3"
                      end
          text_path = call.format_recording(format)
          if text_path && File.file?(text_path)
            send_file(text_path, "audio/%s; charset=binary; filename=%s.%s" % [mime_type, id, format])
          else
            Ramaze::Log.error "#{text_path} not available or unconvertable from #{call.current_format} to #{format} for #{id}"
            respond 'Not Found', 404
          end
        end
      else
        Ramaze::Log.error "User does not have permission to listen to Call #{id}"
        respond 'Not Found', 404
      end
    else
      Ramaze::Log.error "Call #{id} does not exist"
      respond 'Not Found', 404
    end
  end

  def format_time(time)
    time.strftime('%Y-%m-%d %H:%M')
  end

  private
  def call_array(call)
    if call.recording_path && call.can_listen?(user)
      audio = %Q{<audio src=\\"/listen/#{call.id}.wav\\" preload=\\"none\\" controls> Your browser does not support the <code>audio</code> element. Please use one of the file format downloads.  </audio>}
      playback = %Q{<a href=\\"/listen/#{call.id}.mp3\\">MP3</a> <a href=\\"/listen/#{call.id}.ogg\\">OGG</a> <a href=\\"/listen/#{call.id}.wav\\">WAV</a>}
    else
      audio = playback = "N/A"
    end

    '[ "%s", "%s", "%s", "%s", "%s", "%s", "%s", "%s" ]' % [
      (call.username == call.caller_id_number ? (call.caller_id_number =~ /^\d\d\d\d?$/ ? call.caller_id_number : "") : call.username),
      call.caller_id_number,
      ::CGI.unescape(call.caller_id_name.to_s),
      call.destination_number,
      format_time(call.start_stamp),
      call.duration,
      audio,
      playback
    ]
  end
end
