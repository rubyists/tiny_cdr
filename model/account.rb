require "digest/sha1"
module TinyCdr
  class Account < Sequel::Model
    set_dataset TinyCdr.db[:accounts]

    attr_accessor :password, :password_confirmation

    def after_create
      self.salt = Digest::SHA1.hexdigest("--%s--%s--" % [Time.now.to_f, username])
      self.crypted_password = encrypt(password)
      @new = false
      save
    end

    def encrypt(password)
      self.class.digestify(password, salt)
    end

    def authenticated?(password)
      crytped_password == encrypt(password)
    end

    def self.authenticate(creds)
      user, password = creds.values_at("login", "password")
      if TinyCdr.options[:use_ldap]
        return LdapUser.authenticate(user, password)
      else
        return false unless account = find(username: user)
        return account unless password
        return account if account.authenticated?(password)
      end
      false
    rescue => error
      Log.error error
      Log.error error.backtrace.join("\n\t")
      false
    end

    def self.digestify(pass, salt)
      Digest::SHA1.hexdigest("--%s--%s--" % [pass, salt])
    end

  end
end
