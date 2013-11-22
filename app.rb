require 'ramaze'
require 'nokogiri'
require 'sequel'
require 'erubis'

require_relative "./lib/tiny_cdr"
require_relative "./options"
TinyCdr::Log.level = Log4r.const_get(TinyCdr.options[:log_level])

# Initialize controllers and models
require_relative 'model/init'
require_relative 'controller/init'
