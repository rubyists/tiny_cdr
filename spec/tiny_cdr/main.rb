# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
require File.expand_path('../../db_helper', __FILE__)
require TinyCdr::ROOT/:app
require TinyCdr::ROOT/:spec/:cdr_data

describe 'main' do
  behaves_like :rack_test

  it 'shows report page' do
    get "/"
    last_response.status.should == 200
    last_response.body.strip.should.not == ''
    doc = Nokogiri::XML(last_response.body)
    p doc
  end

end

