require 'ramaze'
require 'nokogiri'
require 'makura'
require 'sequel'
require 'erubis'

require_relative "./lib/tiny_cdr"
require_relative "./options"

# Initialize controllers and models
require_relative 'controller/init'
require_relative 'model/init'
