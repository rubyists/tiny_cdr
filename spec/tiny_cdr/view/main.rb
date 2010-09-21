# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
require_relative "../../../lib/tiny_cdr"
require_relative "../../db_helper"
require_relative "../../cdr_data"
require_relative "../../../app"

shared :spec_data do
  require 'time'
  behaves_like :makedoc
  @doc1_uuid = make_uuid
  @doc1 = makedoc(first_name: "Mickey",
                  last_name:  "Mouse",
                  start_epoch: Time.parse("2010-02-02 10:15:00").to_i,
                  end_epoch: Time.parse("2010-02-02 10:17:00").to_i,
                  user: '1010',
                  uuid: @doc1_uuid,
                  ip: '172.30.10.10',
                  phone: '9291112222')

  TinyCdr::Call.create_from_xml(@doc1)
end

describe 'index page' do
  behaves_like :rack_test
  behaves_like :spec_data

  it 'loads the index page' do
    get '/'
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.body.strip.should.not == ''

    doc = Nokogiri(last_response.body)
  end

  it 'generates a user_report' do
    get MainController.r(:user_report).to_s, :username => '1010'
    last_response.status.should == 200
    last_response['Content-Type'].should == 'text/html'
    last_response.body.strip.should.not == ''

    doc = Nokogiri(last_response.body)

    (doc/'td.total_calls').text.should == "1"
    (doc/'td.total_time').text.should == "2 minutes"

    (doc/'td.username').text.should == '1010'
    (doc/'td.cid_num').text.should == '1010'
    (doc/'td.cid_name').text.should == 'Mickey Mouse'
    (doc/'td.dest_num').text.should == '9291112222'
    (doc/'td.start').text.should == "02-02-2010 10:15:00"
    (doc/'td.end').text.should == "02-02-2010 10:17:00"
    (doc/'td.duration').text.should == "120"
    (doc/'td.channel').text.should == 'sofia/default/1010@172.30.10.10'
    (doc/'td.context').text.should == 'default'
  end
end
