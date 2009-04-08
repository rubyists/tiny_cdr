require 'rexml/document'

module TinyCDR
  class ScrubXML
    include REXML
    attr_reader :doc, :username, :caller_id_number, :caller_id_name, :destination_number, :channel, :context, :start_stamp, :end_stamp, :duration, :billsec

    def initialize(xml_doc)
      @doc = Document.new(xml_doc)
      request_cdr_info
    end

    def request_cdr_info
      @username = @doc.root.elements["callflow/caller_profile/username"][0].to_s
      @caller_id_number = @doc.root.elements["callflow/caller_profile/caller_id_number"][0].to_s
      @caller_id_name = @doc.root.elements["callflow/caller_profile/caller_id_name"][0].to_s
      @destination_number = @doc.root.elements["callflow/caller_profile/destination_number"][0].to_s
      @channel = @doc.root.elements["callflow/caller_profile/chan_name"][0].to_s
      @context = @doc.root.elements["callflow/caller_profile/context"][0].to_s
      @start_stamp = @doc.root.elements["variables/start_epoch"][0].to_s
      @end_stamp = @doc.root.elements["variables/end_epoch"][0].to_s
      @duration = @doc.root.elements["variables/duration"][0].to_s
      @billsec = @doc.root.elements["variables/billsec"][0].to_s
    end
  end
end
