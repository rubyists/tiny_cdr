#!/usr/bin/env ruby

require "nokogiri"

files = Dir["*.xml"].map{|n| d = Nokogiri::XML(open(n)); next if d.at(:cc_member_uuid); [d,n] }.compact
data = files.map { |(d,n)| [(d.at(:cc_queue), d.at(:start_epoch)] }
good_calls = data.select { |(a,b)| a }
rep = good_calls.map { |(a,b)| [a.text, Time.at(b.text.to_i)] }
grouping = rep.group_by { |(a,b)| [b.day, b.hour, a] }
require 'csv'; csv = CSV.open("new_report.csv", "wb")
grouping.sort.each { |k,v| csv << (k + [v.size]) }
csv.close
