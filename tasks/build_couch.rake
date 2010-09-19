# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
desc 'build couchdb and its dependencies'
task :build_couch do

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
    while out = sout.gets.strip
      puts out unless out.empty?
    end
  ensure
    sout.close rescue nil
  end

end
