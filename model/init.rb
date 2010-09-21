require 'nokogiri'
require 'cgi'
require 'makura'
require 'sequel'
require_relative "../lib/tiny_cdr"

Makura::Model.server = 'http://localhost:5984'

case Innate.options.mode
when :spec
  Makura::Model.database = 'tiny_cdr_spec'
else
  Makura::Model.database = 'tiny_cdr'
  require "tiny_cdr/db"
end

DB = TinyCdr.db

# Here go your requires for models:
require_relative 'call'
require_relative 'log'
