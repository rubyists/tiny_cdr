class Log
  include Makura::Model

  properties :channel_data, :variables, :app_log, :callflow

  def self.create_from_xml(xml)
    parser = LogParser.new
    Nokogiri::XML::SAX::Parser.new(parser).parse(xml)
    instance = Log.new(parser.out['cdr'])
    instance.save
    return instance
  end
end

class LogParser < Nokogiri::XML::SAX::Document
  attr_reader :out

  def start_document
    @keys = []
    @out = {}
  end

  def start_element(name, attrs = [])
    @keys << name
    @attrs = Hash[*attrs]
    @buffer = []
  end

  def characters(string)
    @buffer << string
  end

  INTEGER = %w[
    sip_received_port sip_contact_port sip_via_port sip_via_rport max_forwards
    write_rate local_media_port sip_term_status read_rate
  ]

  def end_element(name)
    content = @buffer.join.strip
    content =
      case name
      when /(time|sec|epoch|duration)$/, *INTEGER
        Integer(content)
      else
        case content
        when 'true'
          true
        when 'false'
          false
        when ''
          nil
        else
          CGI.unescape(content)
        end
      end

    if @keys == %w[cdr app_log application] ||
       @keys == %w[cdr callflow extension application]

      @keys.inject(@out){|s,v|
        if v == 'application'
          (s[v] ||= []) << {@attrs['app_name'] => @attrs['app_data']}
        else
          s[v] ||= {}
        end
      }
    else
      @keys.inject(@out){|s,v|
        if content && v == @keys.last && @buffer.any?
          s[v] = content
        else
          s[v] ||= {}
        end
      }
    end

    @keys.pop
    @buffer.clear
  end
end
