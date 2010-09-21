# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
require "digest/md5"

FIRST_NAMES = %w{Mike Amy John Peter Mary George Steve Brandon Kelly Donna Paul Fred Allison}
LAST_NAMES = %w{Johnson Jefferson Washington Madison Adams Jackson Lincoln}

shared :makedoc do
  def make_uuid
    require "securerandom"
    SecureRandom.uuid
  end

  def makedoc(args = {})
    user        = args[:user]         || 1000 + rand(9000)
    phone       = args[:phone]        || 1000000000 + rand(8999999999)
    ip          = args[:ip]           || "172.25.25.#{rand(255)}"
    agent_first = args[:first_name]   || FIRST_NAMES[rand(FIRST_NAMES.size)]
    agent_last  = args[:last_name]    || LAST_NAMES[rand(LAST_NAMES.size)]
    uuid        = args[:uuid]         || make_uuid
    start_epoch = args[:start_epoch]  || 1000000000 + rand(284904211)
    end_epoch   = args[:end_epoch]    || start_epoch + rand(400)
    duration    = args[:duration]     || (end_epoch - start_epoch).to_i
    doc = <<-XML
<?xml version="1.0"?>
<cdr>
  <channel_data>
    <state>CS_REPORTING</state>
    <direction>inbound</direction>
    <state_number>11</state_number>
    <flags>0=1;36=1;38=1;51=1</flags>
    <caps>1=1;2=1;3=1</caps>
  </channel_data>
  <variables>
    <uuid>#{uuid}</uuid>
    <sip_network_ip>#{ip}</sip_network_ip>
    <sip_network_port>56866</sip_network_port>
    <sip_received_ip>#{ip}</sip_received_ip>
    <sip_received_port>56866</sip_received_port>
    <sip_via_protocol>udp</sip_via_protocol>
    <sip_from_user>#{user}</sip_from_user>
    <sip_from_uri>#{user}%40#{ip}</sip_from_uri>
    <sip_from_host>#{ip}</sip_from_host>
    <sip_from_user_stripped>#{user}</sip_from_user_stripped>
    <start_epoch>#{start_epoch}</start_epoch>
    <end_epoch>#{end_epoch}</end_epoch>
    <sip_from_tag>BD37552C-4B5</sip_from_tag>
    <duration>#{duration}</duration>
  </variables>
  <app_log>
    <application app_name="set" app_data="continue_on_fail=true">
    </application>
    <application app_name="bridge"
    app_data="sofia/external/gateway/gw001/#{user}"></application>
    <application app_name="bridge"
    app_data="sofia/external/gateway/gw002/#{user}"></application>
  </app_log>
  <callflow dialplan="XML" profile_index="1">
    <extension name="#{user}" number="#{user}">
      <application app_name="set" app_data="continue_on_fail=true">
      </application>
      <application app_name="bridge"
      app_data="sofia/external/gateway/gw001/#{user}"></application>
      <application app_name="bridge"
      app_data="sofia/external/gateway/gw002/#{user}"></application>
      <application app_name="bridge"
      app_data="sofia/external/gateway/gw003/#{user}"></application>
      <application app_name="bridge"
      app_data="sofia/external/gateway/gw004/#{user}"></application>
      <application app_name="bridge"
      app_data="sofia/external/gateway/gw005/#{user}"></application>
    </extension>
    <caller_profile>
      <username>#{user}</username>
      <dialplan>XML</dialplan>
      <caller_id_name>#{agent_first} #{agent_last}</caller_id_name>
      <ani>#{user}</ani>
      <aniii></aniii>
      <caller_id_number>#{user}</caller_id_number>
      <network_addr>#{ip}</network_addr>
      <rdnis>#{user}</rdnis>
      <destination_number>#{phone}</destination_number>
      <uuid>#{uuid}</uuid>
      <source>mod_sofia</source>
      <context>default</context>
      <chan_name>sofia/default/#{user}@#{ip}</chan_name>
    </caller_profile>
    <times>
      <created_time>#{start_epoch * 1000000}</created_time>
      <profile_created_time>1274439432448060</profile_created_time>
      <progress_time>0</progress_time>
      <progress_media_time>0</progress_media_time>
      <answered_time>0</answered_time>
      <hangup_time>#{end_epoch * 1000000}</hangup_time>
      <resurrect_time>0</resurrect_time>
      <transfer_time>0</transfer_time>
    </times>
  </callflow>
</cdr>
    XML
  end
end
