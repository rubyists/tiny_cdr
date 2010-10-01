#!/usr/bin/env ruby

module TinyCdr
  module ODSReport
    module ByExtensionAndDate
      module_function

      def generate(argv = ARGV)
        require 'optparse'
        require 'optparse/date'
        require 'yaml'

        options = {
          out: ENV['TINYCDR_REPORT_FILE'] || 'report.ods',
          in: ENV['EXTENSION_LIST'] || 'extensions.yaml',
          avoid_locals: true,
          generate: {},
        }

        op = OptionParser.new{|o|
          o.on('-i', '--in FILE', "Read exts from this file (#{options[:out]}") do |file|
            options[:in] = file
          end

          o.on("-f", "--from DATE", Date, "Report starts on this date (to 1st of current month)") do |from|
            options[:from] = from
          end

          o.on("-t", "--to DATE", Date, "Report ends with this date (defaults to 1 month after --from)") do |to|
            options[:to] = to
          end

          o.on("-i", "--include-locals", "Include internal calls") do |include_locals|
            options[:avoid_locals] = false
          end

          o.on('-c', '--couchdb FILE', 'Generate CouchDB report and store in FILE') do |file|
            options[:generate][:generate_from_couchdb] = file
          end

          o.on('-p', '--postgres FILE', 'Generate PostgreSQL report and store in FILE') do |file|
            options[:generate][:generate_from_postgresql] = file
          end
        }

        if argv.empty?
          puts op
          exit 1
        else
          op.parse(argv)
        end

        options[:out] = File.expand_path(options[:out])
        options[:in] = File.expand_path(options[:in])

        now = Time.now
        from = options[:from] ||= Time.new(now.year, now.month, 1)
        options[:to] ||= Time.new(from.year, from.month + 1, 1)
        options[:exts] = YAML.load_file(options[:in])

        unless File.exists?(options[:out])
          puts options
          raise "Report with this name already exists: #{options[:out]}"
        end

        require 'spreadsheet'
        require_relative "../model/init"

        options[:generate].each do |method, destination|
          sheet = send(method, options)

          File.open(destination, 'wb+') do |file|
            file.write sheet.content!
          end
        end
      end

      def write_header(sheet, ext, fullname, row_count, total_talk_time)
        sheet.header do
          sheet.row do
            sheet.cell "Call Detail for #{ext} - #{fullname}", style: 'title', span: 9
          end

          sheet.row do
            sheet.cell 'Total Calls', style: 'bold'
            sheet.numeric_cell row_count

            sheet.cell 'Total Talk Time', style: 'bold'
            sheet.numeric_cell total_talk_time
          end

          sheet.row do
            sheet.cell 'CID Number', style: 'bold'
            sheet.cell 'CID Name', style: 'bold'
            sheet.cell 'Destination Number', style: 'bold'
            sheet.cell 'Start', style: 'bold'
            sheet.cell 'End', style: 'bold'
            sheet.cell 'Duration', style: 'bold'
            sheet.cell 'Channel', style: 'bold'
            sheet.cell 'Context', style: 'bold'
            sheet.cell 'Identifier', style: 'bold'
          end
        end
      end

      def generate_from_couchdb(options)
        sheet = Spreadsheet::Builder.new

        sheet.spreadsheet do
          options[:exts].each do |ext, fullname|
            rows = options[:db].view(
              'log/_view/call_detail_avoid_locals',
              startkey: [ext, options[:from].to_i],
              endkey: [ext, options[:to].to_i]
            )['rows']

            p "#{ext} #{rows.size}"

            total_talk_time = rows.inject(0){|sum, row|
              sum + row["value"]["duration"].to_i
            } / 60

            sheet.table "#{ext} - #{fullname}" do
              write_header sheet, ext, fullname, rows.size, total_talk_time
              rows.each do |row|
                sheet.row do
                  doc = row["value"]
                  sheet.string_cell  doc["caller_id_number"]
                  sheet.string_cell  doc["caller_id_name"]
                  sheet.string_cell  doc["destination_number"]
                  sheet.string_cell  Time.at(doc["start"]).strftime("%m/%d/%Y %H:%M:%S")
                  sheet.string_cell  Time.at(doc["end"]).strftime("%m/%d/%Y %H:%M:%S")
                  sheet.numeric_cell doc["duration"]
                  sheet.string_cell  doc["chan_name"]
                  sheet.string_cell  doc["context"]
                  sheet.string_cell  row["id"]
                end
              end
            end
          end
        end

        sheet
      end

      def generate_from_postgresql(options)
        sheet.spreadsheet do
          options[:exts].each do |ext, fullname|
            rows = options[:model].user_report(
              options[:from], options[:to], :username => ext
            ).all

            p "#{ext} #{rows.size}"

            total_talk_time = rows.inject(0){|sum, row|
              sum + row[:duration].to_i
            } / 60

            sheet.table "#{ext} - #{fullname}" do
              write_header ext, fullname, rows.size, total_talk_time
              rows.each do |row|
                sheet.row do
                  sheet.string_cell  row[:caller_id_number]
                  sheet.string_cell  row[:caller_id_name]
                  sheet.string_cell  row[:destination_number]
                  sheet.string_cell  Time.at(row[:start_stamp]).strftime("%m/%d/%Y %H:%M:%S")
                  sheet.string_cell  Time.at(row[:end_stamp]).strftime("%m/%d/%Y %H:%M:%S")
                  sheet.numeric_cell row[:duration]
                  sheet.string_cell  row[:channel]
                  sheet.string_cell  row[:context]
                  sheet.string_cell  row[:couch_id]
                end
              end
            end
          end
        end

        sheet
      end
    end
  end
end

if $0 == __FILE__
  TinyCdr::ODSReport::ByExtensionAndDate.generate(ARGV)
end
