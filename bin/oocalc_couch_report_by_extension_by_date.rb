#!/usr/bin/env ruby
require 'time'
require 'spreadsheet'
require_relative "../model/init"

# Installation:
#
# $ gem install rubyzip builder makura
#
# Also:
#   * http://github.com/rubyists/spreadsheet
#
#
# Amend when we find something missing.

#Makura::Model.server = 'http://jimmy:5984'
#Makura::Model.database = 'tiny_cdr'
#db = Makura::Model.database
# Need to pull this from a file (later db)
module TinyCdr
  module OOReport
    class ByExtensionAndDate
      def initialize(start, stop, options = {})

        @sheet = Spreadsheet::Builder.new
        @exts  = options[:extensions]
        @from  = start
        @to    = stop
        @db    = Makura::Model.database
      end

      def generate
        @sheet.spreadsheet do
          @exts.each do |ext, fullname|
            res = @db.view(
              'log/_view/call_detail_avoid_locals',
              startkey: [ext, @from],
              endkey: [ext, @to]
            )
            rows = res['rows']
            p "#{ext} #{rows.size}"

            total_talk_time = rows.inject(0){|sum, row| sum + row["value"]["duration"].to_i }/60

            @sheet.table "#{ext} - #{fullname}" do
              write_header ext, fullname, rows.size, total_talk_time
              rows.each { |row| write_row row }
            end
          end
        end
        @sheet
      end

      def write_header(ext, fullname, row_count, total_talk_time)
        @sheet.header do
          @sheet.row do
            @sheet.cell "Call Detail for #{ext} - #{fullname}", style: 'title', span: 8
          end

          @sheet.row do
            @sheet.cell 'Total Calls', style: 'bold'
            @sheet.numeric_cell row_count

            @sheet.cell 'Total Talk Time', style: 'bold'
            @sheet.numeric_cell total_talk_time
          end

          @sheet.row do
            @sheet.cell 'CID Number', style: 'bold'
            @sheet.cell 'CID Name', style: 'bold'
            @sheet.cell 'Destination Number', style: 'bold'
            @sheet.cell 'Start', style: 'bold'
            @sheet.cell 'End', style: 'bold'
            @sheet.cell 'Duration', style: 'bold'
            @sheet.cell 'Channel', style: 'bold'
            @sheet.cell 'Context', style: 'bold'
          end
        end
      end

      def write_row(row)
        @sheet.row do
          doc = row["value"]
          @sheet.string_cell  doc["caller_id_number"]
          @sheet.string_cell  doc["caller_id_name"]
          @sheet.string_cell  doc["destination_number"]
          @sheet.string_cell  Time.at(doc["start"]).strftime("%m/%d/%Y %H:%M:%S")
          @sheet.string_cell  Time.at(doc["end"]).strftime("%m/%d/%Y %H:%M:%S")
          @sheet.numeric_cell doc["duration"]
          @sheet.string_cell  doc["chan_name"]
          @sheet.string_cell  doc["context"]
        end
      end
    end
  end
end

if $0 == __FILE__
  require "yaml"
  require "optparse"
  require "date"

  today = Time.now

  options = {:from => Time.mktime(today.year, today.month, 1),
             :output_file => "report.ods",
             :to   => Time.mktime(today.year, today.month + 1, 1),
             :exts => YAML.load(File.read(ENV["EXTENSION_LIST"])),
             :avoid_locals => true}

  # OptParsing goes here
  OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options]"
    opts.separator ""
    opts.separator "Specific options:"

    opts.on("-f", "--from [STARTDATE]", "Report from STARTDATE mm/dd/yyyy") do |from|
      options[:from] = Date.strptime(from, "%m/%d/%Y").to_time unless from.empty?
    end

    opts.on("-t", "--to [STOPDATE]", "Report from STOPDATE mm/dd/yyyy") do |to|
      options[:to] = Date.strptime(to, "%m/%d/%Y").to_time unless to.empty?
    end

    opts.on("-i", "--include-locals", "Include internal calls") do |include_locals|
      options[:avoid_locals] = false if include_locals
    end

    opts.on("-a", "--avoid-locals", "Exclude internal calls") do |exclude_locals|
      options[:avoid_locals] = true if exclude_locals
    end
  end

  exts = options[:exts]
  output_file = options[:output_file]
  from = options[:from].to_i
  to = options[:to].to_i
  avoid_locals = options[:avoid_locals]
  raise "Report with this name already exists: #{output_file}" if File.exists?(output_file)

  sheet = TinyCdr::OOReport::ByExtensionAndDate.new(from, to, :avoid_locals => avoid_locals, :extensions => exts).generate
  File.open(output_file, 'wb+') do |f|
    f.write sheet.content!
  end
end
