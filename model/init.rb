require 'nokogiri'
require 'cgi'

# Here goes your database connection and options:
require 'makura'
Makura::Model.server = 'http://localhost:5984'
Makura::Model.database = 'tiny_cdr'

require 'sequel'
require_relative "../lib/tiny_cdr"
require "tiny_cdr/db"
DB = TinyCdr.db
#TinyCdr.db = Sequel.postgres('tiny_cdr', :host => "localhost")

# Here go your requires for models:
require_relative 'call'
require_relative 'log'
