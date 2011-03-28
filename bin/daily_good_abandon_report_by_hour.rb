#!/usr/bin/env ruby

require "json"
require "open-uri"
require "date"

uri = "http://localhost:5984/tiny_cdr/_design/log/_view/hourly_report_detail?include_docs=true"

all_call_detail = JSON.parse(open(uri).read)["rows"].map { |cdr| cdr["doc"] }
day_start_epoch = Date.today.to_time.to_i
day_end_epoch = day_start_epoch+86400

call_details = JSON.parse(open(uri).read)[:rows].map { |cdr| cdr["doc"] }
