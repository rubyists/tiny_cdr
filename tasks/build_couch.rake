# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
desc 'build couchdb and its dependencies'
task :build_couch do
  has_couch = %x{which couchdb}
  if has_couch
    puts "You have a couchdb in your path"
    couch_version = %x{couchdb -V|head -1|awk '{print $NF}'}.to_s.strip
    puts "Your couchdb version is #{couch_version}"
    if couch_version == "1.0.1"
      puts "You already have couchdb version 1.0.1, no need to build a new one!"
      exit
    end
  end
  puts "No couchdb 1.0.1 found in $PATH, building one now"
  COMMAND_LINE = <<-BASH
    git submodule init && \
    git submodule update && \
    cd dependencies/build-couchdb && \
    git submodule init && \
    git submodule update && \
    rake
  BASH

  begin
    sout = IO.popen("bash -c '#{COMMAND_LINE}'")
    while out = sout.gets
      puts out.strip unless out.empty?
    end
  ensure
    sout.close rescue nil
  end
  puts "
Couch has probably built, if all you see is an

  rm -rf '#{ENV['PWD']}/dependencies/build-couchdb/build'/lib/erlang/lib/mnesia-*
  rake aborted!
  No such file or directory
  
  error, ignore it and try starting couch with

  ./dependencies/build-couchdb/build/bin/couchdb

  if it runs you're good to go.
  "

end
