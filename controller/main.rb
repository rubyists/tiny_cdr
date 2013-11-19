require 'date'
require File.dirname(__FILE__) + '/../lib/daily_good_abandon_report_by_hour.rb'
class MainController < Controller
  layout :main
  helper :xhtml, :send_file
  engine :Erubis

  # the index action is called automatically when no other action is specified
  def index
    redirect :search
  end

  def search
    @head  = '<script type="text/javascript" src="/js/index.js"></script>'
    @title = "TinyCDR - FreeSWITCH CDR Reporting"
  end

  def give_file
    filename = request[:filename]   
    render_file(filename,:content_type => "application/excel" )
  end

  def inbound_stats
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
    start, stop = request[:date_start, :date_end]
    username, phone_number = request[:username, :phone_number].map{|s| s.to_s.strip }
    username = nil if username.empty?
    phone_number = nil if phone_number.empty?
    @title = "Call Detail"
    @title << " for #{username}" unless username.nil?
    @title << " for #{phone_number}" unless phone_number.nil?
    queue_only = (request[:queue_only].empty? ? false : true) rescue nil
    avoid_locals = (request[:avoid_locals].empty? ? false : true) rescue nil
    locals_only = (request[:locals_only].empty? ? false : true) rescue nil

    ds = TinyCdr::Call.user_report(start, stop, {:username => username,
                                                 :phone    => phone_number,
                                                 :queue_only    => queue_only,
                                                 :locals_only    => locals_only,
                                                 :avoid_locals => avoid_locals})
    @calls = ds.all

    @total_time = @calls.inject(0) {|a,b| a + b.duration.to_i }/60
  end

  def listen(format, id)
    require "cgi"
    if call = TinyCdr::Call[id: id]
      if call.recording_path.nil?
        Ramaze::Log.error "Call #{id} #{call.recording_path} not available"
        respond 'Not Found', 404
      else
        text_path = call.recording_path
        if File.file?(text_path)
          send_file(text_path, 'audio/x-wav; charset=binary; filename=' + id + '.wav')
        else
          Ramaze::Log.error "#{text_path} not available"
          respond 'Not Found', 404
        end
      end
    else

      respond 'Not Found', 404
    end
  end

  def user_report_couch
    @title = "Call Detail for #{h request[:username]}"
    view = request[:avoid_locals] ? 'call_detail_avoid_locals' : 'call_detail'

    @calls = Makura::Model.database.view(
      "log/_view/#{view}",
      startkey: [request[:username], Time.strptime(request[:date_start], '%m/%d/%Y').to_i],
      endkey: [request[:username], Time.strptime(request[:date_end], '%m/%d/%Y').to_i]
    )['rows'].map{|row| row['value'] }
  end

  def format_time(time)
    time.strftime('%Y-%m-%d %H:%M')
  end
end
