#!/usr/bin/env ruby

require "./model/init"

files = Dir.glob(File.join(File.expand_path(ARGV[0]), "*.xml"))

puts "Found #{files.size} files to import from #{ARGV[0]}"
files.each do |f| 
  if File.size(f) > 10
    uuid = File.basename(f).split(".").first
    txt = File.read(f)
    txt = CGI.unescape(txt) unless txt.start_with?("<")
    begin
      TinyCdr::Log.find_or_create_from_xml(uuid,txt)
      FileUtils.mv(f, "archived/")
    rescue Sequel::InvalidValue
      warn "Bad record #{f}"
    end
  else 
    warn "No data in file #{f}"
  end 
end
