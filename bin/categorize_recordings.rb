#!/usr/bin/env ruby
require "fileutils"
require_relative "../app"
Dir.chdir TinyCdr.options[:base_record_path]
puts "In #{Dir.pwd}"
today = Date.today.strftime("%Y%m%d")
puts "Today is #{today}"
if __FILE__ == $0
  Dir["????????-*-*-*-*.wav"].each do |recording|
    if today != recording[0,8]
      year  = recording[0,4]
      month = recording[4,2]
      day   = recording[6,2]
      dir = "%s/%s/%s" % [year,month,day]
      puts dir
      unless File.directory?(dir)
        FileUtils.mkdir_p dir
        FileUtils.chmod 0755, dir
      end
      puts "Moving #{recording} to #{dir}"
      if FileUtils.mv(recording, dir)
        if call = TinyCdr::Call.find(:recording => /.*#{Regexp.escape(File.basename(recording))}/)
          db_path = File.join(TinyCdr.options[:mounted_record_path], dir, File.basename(recording))
          puts "Updating db path to #{db_path}"
          call.recording = db_path
          call.save
        end
      end
    else
      puts "Not moving #{recording}"
    end
  end
end

