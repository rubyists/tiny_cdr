require 'ramaze'

Ramaze.setup do
  gem 'nokogiri'
  gem 'makura'
  gem 'sequel'
  gem 'erubis'
end

# Initialize controllers and models
require_relative 'controller/init'
require_relative 'model/init'
