# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers

class Controller < Ramaze::Controller
end

# Here go your requires for subclasses of Controller:
require 'rexml/document'
require 'controller/main'
require 'controller/cdr'
