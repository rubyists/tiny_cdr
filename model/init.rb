require 'nokogiri'
require 'sequel'
require_relative "../lib/tiny_cdr"
require_relative '../lib/tiny_cdr/db'

DB = TinyCdr.setup_db

# Here go your requires for models:
require_relative 'call'
require_relative 'account'
if TinyCdr.options[:use_ldap]
  require_relative 'ldap_user'
end
