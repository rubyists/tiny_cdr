# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
require 'nokogiri'
require 'ramaze/spec/bacon'
Ramaze::Log.loggers = [Logger.new(TinyCdr::ROOT/:log/"ramaze_spec.log")]
Ramaze.middleware! :spec do |m|
  m.use Rack::Lint
  m.use Rack::CommonLogger, Ramaze::Log
  m.run Ramaze::AppMap
end

Ramaze.options.roots = [TinyCdr::ROOT]
