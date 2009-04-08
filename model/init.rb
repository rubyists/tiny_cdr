# Here goes your database connection and options:
require 'sequel'
DB = Sequel.connect("sqlite://db/tiny_cdr.db")

# Here go your requires for models:
# require 'model/user'
require File.join(File.dirname(__FILE__), "..", 'lib', 'tiny_cdr')
require File.join(File.dirname(__FILE__), 'call')
