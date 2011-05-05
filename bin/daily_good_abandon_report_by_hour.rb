#!/usr/bin/env ruby

require "json"
require "open-uri"
require "date"
require "csv"

class DailyGoodAbandonReportByHour
  #all_call_detail = JSON.parse(open(uri).read)["rows"].map { |cdr| cdr["doc"] }
  def initialize(args)
    argdate = args[:argdate]
    @day_end_epoch = Date.today.to_time.to_i
    @view_calls = []
    begin
     if argdate then
      @day_end_epoch = Date.strptime(argdate,"%m/%d/%Y").to_time.to_i
     end  
    rescue
      raise "must supply a valid date in mm/dd/yyyy format"
    end
  end
  def create_report
    day_start_epoch = @day_end_epoch-86400
    rdate = Time.at(day_start_epoch)
    year, month, day = rdate.year, rdate.month , rdate.day
    @filename = "/tmp/InboundHourly#{year}-#{month}#{day}.csv"
    uri = "http://jupiter:5984/tiny_cdr/_design/log/_view/hourly_report_detail?startKey=#{day_start_epoch}&endKey=#{@day_end_epoch}&include_docs=true"

    puts uri
    call_details = JSON.parse(open(uri).read)["rows"].map { |cdr| cdr["doc"] }
    h = {}
    call_details.map do |call|
      variables = call["variables"]
      queue, joined, cancelled = variables.values_at("cc_queue", "cc_queue_joined_epoch", "cc_queue_canceled_epoch")
      #  puts "queue is #{variables["cc_queue"]} billsec is #{variables["billsec"]} duration is #{variables["duration"]}" if (variables["billsec"] == 0)
      dropped_call = cancelled ? 1 : 0 #  (variables["duration"] > 0 && variables["billsec"] == 0) ? 1 : 0
      time = Time.at(joined)
      cancelled_categories = [0,0,0]
      if cancelled
        case variables["duration"]
          when 0..5 then cancelled_categories[0] = 1
          when 6..10 then cancelled_categories[1] = 1
          else cancelled_categories[2] = 1
        end
        File.open("/tmp/cancelled_#{variables["cc_queue"]}_#{time.strftime("%Y%m%d-%H")}.json", "a+") { |f| f.puts call.to_json }
      end
      h[[time.hour, queue]] ||= [] 
      h[[time.hour, queue]] << [1, dropped_call, cancelled_categories ].flatten  
      # start building rows for each hr
      #line = []
    end
      lines = []
      h.keys.sort.map do |hourqueue|
         hc_total, dropped_total,l5,l10,others = 0,0,0,0,0,0
         h[hourqueue].map do |data|
           hc_total+=data[0]
           dropped_total+=data[1]
           l5+=data[2]
           l10+=data[3]
           others+=data[4]
         end
         lines << [hourqueue,hc_total, dropped_total,l5,l10,others].flatten!
      end
      CSV.open(@filename,"w") do |csv|
        csv << ["Hr","Queue","Total Inbound","Dropped","Less than 5 Seconds","5 to 10","more then 10 Seconds"]
              
      lines.map do |l|
        line =  [Time.local(year,month,day,l[0]).strftime("%D %I:%M%p"),l[1],l[2],l[3],l[4],l[5],l[6] ]
        @view_calls << line
        csv << line
      end
    end
  end
end

if $0 == __FILE__
          argdate = ARGV[0]
          rep = DailyGoodAbandonReportByHour.new(:argdate => argdate)
          rep.create_report
end

