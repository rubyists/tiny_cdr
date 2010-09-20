require 'date'
class MainController < Controller
  layout :main
  helper :xhtml
  engine :Erubis

  # the index action is called automatically when no other action is specified
  def index
    @head  = '<script type="text/javascript" src="/js/index.js"></script>'
    @title = "TinyCDR - FreeSWITCH CDR Reporting"
  end

  def user_report
    start, stop = request[:date_start, :date_end]
    username, phone_num = request[:username, :phone_num].map{|s| s.to_s.strip }
    username = nil if username.empty?
    phone_num = nil if phone_num.empty?
    @title = "Call Detail"
    @title << " for #{username}" unless username.nil?
    avoid_locals = (request[:avoid_locals].empty? ? false : true) rescue nil

    conditionals = 'username = ? or caller_id_number = ? or destination_number = ?'

    filter =
      if username && phone_num
        [ "(#{conditionals}) and (#{conditionals})",
          username, username, username,
          phone_num, phone_num, phone_num ]
      elsif username
        [conditionals, username, username, username]
      elsif phone_num
        [conditionals, phone_num, phone_num, phone_num]
      end
    ds = (filter ? TinyCdr::Call.filter(filter) : TinyCdr::Call)
    ds = ds.filter{start_stamp >= Date.strptime(start, "%m/%d/%Y") } if !(start.nil? or start.empty?)
    ds = ds.filter{end_stamp <= Date.strptime(stop, "%m/%d/%Y") } if !(stop.nil? or stop.empty?)
    ds = ds.filter("caller_id_number ~ '^\\d\\d\\d\\d\\d+$' or destination_number ~ '^\\d\\d\\d\\d\\d+$'") if avoid_locals
    ds = ds.order(:start_stamp)
    p ds.sql # Output the raw sql
    @calls = ds.all
  end

  def user_report_couch
    @title = "Call Detail for #{h request[:username]}"
    view = request[:avoid_locals] ? 'call_detail_avoid_locals' : 'call_detail'

    @calls = Makura::Model.database.view(
      "report/_view/#{view}",
      startkey: [request[:username], Time.strptime(request[:date_start], '%m/%d/%Y').to_i],
      endkey: [request[:username], Time.strptime(request[:date_end], '%m/%d/%Y').to_i]
    )['rows'].map{|row| row['value'] }
  end
end
