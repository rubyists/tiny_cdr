require 'net-ldap'
module TinyCdr
  class LdapUser
    attr_reader :ldap, :username

    HOST = TinyCdr.options[:ldap_host]
    PORT = TinyCdr.options[:ldap_port]
    DOMAIN = TinyCdr.options[:ldap_domain]
    USER_ATTRIB = TinyCdr.options[:ldap_user_attrib]
    PHONE_ATTRIB = TinyCdr.options[:ldap_phone_attrib].to_sym
    BASE = TinyCdr.options[:ldap_base]

    def self.authenticate(user, password)
      user = new(user, password)
    end

    def initialize(user, password)
      @users = {}
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

    def phone_filter(num)
      Net::LDAP::Filter.ex(PHONE_ATTRIB, num)
    end

    def user_filter
      Net::LDAP::Filter.ex(USER_ATTRIB, @username)
    end

    def [](attribute)
      val = attributes[attribute]
      val.count == 1 ? val.first : val
    end

    def attributes
      return false unless @username
      return @attributes if @attributes
      search_result = @ldap.search(:base => BASE, :filter => user_filter)
      if search_result.count == 1
        @attributes = search_result.first
      else
        Log.error "Ldap search returned #{search_result.count} results!"
        {}
      end
    end

    def extension_to_user(extension)
      return @users[extension] if @users[extension]
      search_result = @ldap.search(:base => BASE, :filter => phone_filter(extension))
      if search_result.count == 1
        @users[extension] = search_result.first
      else
        nil
      end
    end

    def extension_to(attribute, extension)
      attribute = attribute.to_sym
      attr = case attribute
      when :username
        :sAMAccountName
      when :name, :fullname
        :cn
      when :firstname, :first_name
        :givenname
      when :lastname, :last_name, :surname
        :sn
      else
        attribute
      end
      if user = extension_to_user(extension)
        if val = user[attr]
          val.count == 1 ? val.first : val
        else
          nil
        end
      else
        nil
      end
    end

    def extension
      extensions.first
    end

    def extensions
      @extensions ||= attributes[PHONE_ATTRIB]
    end

    def manager
      db_user.manager
    end

    def db_user
      return @db_user if @db_user
      if account = Account.find(:username => @username)
        @db_user = account
        if @db_user.extension != extension
          @db_user.extension = extension
          @db_user.save
        end
        @db_user
      else
        @db_user = create_account
      end
    end

    def inspect
      "<##{self.class.name} user: #{username} extension: #{extension}>"
    end

    private
    def create_account
      password = Digest::SHA1.hexdigest("--%s--%s--" % [attributes[:dn].first, rand(10000000)])
      Account.create(username: @username, password: password, password_confirmation: password, extension: extension)
    end

    def authorized?
      @ldap.bind
    end
  end
end
