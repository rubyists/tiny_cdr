# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
desc 'install all possible dependencies'
task :setup => :gem_setup do
  GemSetup.new do
    # core
    gem 'ramaze'
    gem 'nokogiri'
    gem 'makura'
    gem 'sequel'
    gem 'pg'

    # spec
    gem 'bacon'

    # doc
    gem 'yard'

    setup
  end
end
