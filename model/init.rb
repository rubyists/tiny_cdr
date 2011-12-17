require 'nokogiri'
require 'sequel'
require_relative "../lib/tiny_cdr"
require_relative '../lib/tiny_cdr/db'

DB = TinyCdr.setup_db

# Here go your requires for models:
require_relative 'call'
