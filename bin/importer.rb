#!/usr/bin/env ruby
require_relative '../model/init'
require 'pp'
Makura::Model.database = 'tiny_cdr'
db = Makura::Model.database

# You must set these to run the importer
endkey = 'ffffcea6-c269-11df-8955-a7a8d4dd201b' # last key in db
startkey = '00000446-b696-11df-9821-a7a8d4dd201b' # first key in db

# Don't change anything below here
begin
  rows = db.view('log/_view/all', limit: 50000, startkey: startkey)['rows']
  p startkey => rows.size

  startkey = rows.last['id']

  rows.map{|row|
    v = row['value']
    v.keys.each{|k| v[k] = '' if v[k] == {} }

    unless TinyCdr::Call.find(:couch_id => row['id'])
      begin
        TinyCdr::Call.create(
          couch_id:             row['id'],
          username:             v['username'],
          caller_id_number:     v['caller_id_number'],
          caller_id_name:       v['caller_id_name'],
          destination_number:   v['destination_number'],
          channel:              v['chan_name'],
          context:              v['context'],
          start_stamp:          Time.at(v['start']),
          end_stamp:            Time.at(v['end']),
          duration:             v['duration'],
          billsec:              v['billsec']
        )
      rescue Sequel::DatabaseError => e
        warn e
      rescue => ex
        puts ex
        pp row
        exit
      end
    end
    exit if row["id"] == endkey
  }
end while rows.any?
