require 'net-ldap'
module TinyCdr
  class LdapUser
    attr_reader :ldap, :username

    HOST = TinyCdr.options[:ldap_host]
    PORT = TinyCdr.options[:ldap_port]
    DOMAIN = TinyCdr.options[:ldap_domain]
    USER_ATTRIB = TinyCdr.options[:ldap_user_attrib]
    BASE = TinyCdr.options[:ldap_base]

    def self.authenticate(user, password)
      user = new(user, password)
      user.db_user
    end

    def initialize(user, password)
      @ldap = Net::LDAP.new(:host => HOST, :port => PORT)
      if DOMAIN
        @ldap.auth("#{user}@#{DOMAIN}", password)
      else
        @ldap.auth(user, password)
      end
      if authorized?
        @username = user
      end
    end

    def db_user
      return false unless @username
      if user = Account.find(:username => @username)
        return user
      else
        filter = Net::LDAP::Filter.eq(USER_ATTRIB, @username)
        @ldap.search(:base => BASE, :filter => filter)
      end
    end
    private
    def authorized?
      @ldap.bind
    end

    #def inspect
      #"<##{self.class.name} #{values.reject { |k,v| k.to_s == "original" }}>"
    #end
  end
end
