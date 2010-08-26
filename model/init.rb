require 'nokogiri'
require 'cgi'

# Here goes your database connection and options:
require 'makura'
Makura::Model.server = 'http://192.168.6.250:5984'
Makura::Model.database = 'tiny_cdr'

require 'sequel'
DB = Sequel.postgres('tiny_cdr', :host => "localhost")

# Here go your requires for models:
# require 'model/user'
require File.expand_path('../../lib/tiny_cdr', __FILE__)
require File.expand_path('../call', __FILE__)
require File.expand_path('../log', __FILE__)

CDR_LOG_PARSER = Nokogiri::XML::SAX::Parser.new(LogParser.new)
