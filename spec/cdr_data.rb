# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
require TinyCdr::SPEC_HELPER_PATH/:db_helper

call1 = Call.create(:username=>"0000000000",
                             :caller_id_number=>"0000000000",
                             :caller_id_name=>"smg_prid",
                             :destination_number=>"2347",
                             :channel=>"sofia/internal/pip@192.168.6.240",
                             :context=>"default",
                             :start_stamp=>"2010-08-25 10:12:32 -0500",
                             :end_stamp=>"2010-08-25 10:22:47 -0500",
                             :duration=>"615",
                             :billsec=>"614")
