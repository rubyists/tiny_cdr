require 'sequel'
require 'logger'
require 'fileutils'
require_relative "../../options"

module TinyCdr
  @db = nil

  class << self
    attr_writer :db

    def db
      @db ||= setup_db
    end

    def setup_db(name = options.pg_dbname)
      self.db = ::Sequel.postgres(name, parse_pgpass(name))
    end

    def setup_loggers
      path = File.expand_path("../../../log", __FILE__)
      FileUtils.mkdir_p(path)
      file = "#{path}/#{ENV['APP_ENV'] || 'development'}.log"
      [::Logger.new(file)]
    end

    def parse_pgpass(demanded_database)
      options = {
        host: 'localhost',
        port: 5432,
        user: ENV['USER'],
        password: nil,
        loggers: setup_loggers,
      }

      available_options = {}
      searched_files = []

      open_pgpass do |pgpass|
        searched_files << pgpass.to_path
        pgpass.each_line do |line|
          available_options.merge!(parse_pgpass_line(line))
        end
      end

      if found = available_options[demanded_database] || available_options['*']
        options.merge(found)
      else
        abort 'Neither %p nor "*" found in %p' % [demanded_database, searched_files]
      end
    end

    def open_pgpass(&block)
      [ File.expand_path('../../../.pgpass', __FILE__),
        File.expand_path('~/.pgpass'),
      ].each do |path|
        begin
          File.open(path, 'r', &block)
        rescue Errno::ENOENT
        end
      end
    end

    def parse_pgpass_line(line)
      hostname, port, database, username, password = line.strip.split(':')
      { database => {
          host: hostname,
          port: port,
          user: username,
          password: password
        }.select{|k,v| v && v != '*' }
      }
    end
  end
end
