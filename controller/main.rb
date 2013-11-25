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
    redirect_referer
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
    @title << " for #{phone_number}" unless phone_number.nil?
    @title << " from #{start}" unless start.nil
    @title << " to #{stop}" unless stop.nil
    queue_only = (request[:queue_only].empty? ? false : true) rescue nil
    avoid_locals = (request[:avoid_locals].empty? ? false : true) rescue nil
    locals_only = (request[:locals_only].empty? ? false : true) rescue nil

    ds = TinyCdr::Call.user_report(start, stop, user, {:username => username,
                                                 :phone    => phone_number,
                                                 :queue_only    => queue_only,
                                                 :locals_only    => locals_only,
                                                 :avoid_locals => avoid_locals})
    @calls = ds.all

    @total_time = @calls.inject(0) {|a,b| a + b.duration.to_i }/60
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
end
