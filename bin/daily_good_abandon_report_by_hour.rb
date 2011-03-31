#!/usr/bin/env ruby

require "json"
require "open-uri"
require "date"
require "csv"

#all_call_detail = JSON.parse(open(uri).read)["rows"].map { |cdr| cdr["doc"] }
day_end_epoch = Date.today.to_time.to_i
day_start_epoch = day_end_epoch-86400
rdate = Time.at(day_start_epoch)
year, month, day = rdate.year, rdate.month , rdate.day
uri = "http://jupiter:5984/tiny_cdr/_design/log/_view/hourly_report_detail?startKey=#{day_start_epoch}&endKey=#{day_end_epoch}&include_docs=true"

puts uri
call_details = JSON.parse(open(uri).read)["rows"].map { |cdr| cdr["doc"] }
h = {}
call_details.map do |call|
 variables = call["variables"]
# puts "queue is #{variables["cc_queue"]} billsec is #{variables["billsec"]} duration is #{variables["duration"]}" if (variables["billsec"] == 0)
 dropped_call = variables["cc_queue_canceled_epoch"] ? 1 : 0 #  (variables["duration"] > 0 && variables["billsec"] == 0) ? 1 : 0
 h[[Time.at(variables["cc_queue_joined_epoch"]).hour, variables["cc_queue"]]] ||= [] 
 h[[Time.at(variables["cc_queue_joined_epoch"]).hour, variables["cc_queue"]]] << [1, dropped_call]  
  # start building rows for each hr
  #line = []
 end
 lines = []
 h.keys.sort.map do |hourqueue|
    hc_total, dropped_total = 0,0
    h[hourqueue].map do |data|
      hc_total+=data[0]
      dropped_total+=data[1]
    end
    lines << [hourqueue,hc_total, dropped_total].flatten!
 end

 CSV.open("/tmp/InboundHourly#{year}-#{month}#{day}.csv","w") do |csv|
  csv << ["Hr","Queue","Total Inbound","Dropped"]
 lines.map do |l|
  csv << [Time.local(year,month,day,l[0]).strftime("%D %I:%M%p"),l[1],l[2],l[3]]
 end
end
