require "digest/sha1"
module TinyCdr
  class Manager < Sequel::Model
    set_dataset TinyCdr.db[:managers]
    many_to_one :account
    def filter_calls(ds)
      return ds if view_all
      if view_include and view_exclude
        ds.filter("(username ~ ? or caller_id_number ~ ? or destination_number ~ ?) and (username !~ ? and caller_id_number !~ ? and destination_number !~ ?)", *(([view_include] * 3) + ([view_exclude] * 3)))
      elsif view_include
        ds.filter("username ~ ? or caller_id_number ~ ? or destination_number ~ ?", *([view_include] * 3))
      elsif view_exclude
        ds.filter("username !~ ? and caller_id_number !~ ? and destination_number !~ ?", *([view_exclude] * 3))
      else
        ds
      end
    end

    def can_listen?(call)
      return true if listen_all
      allowed = false
      if listen_include
        match = Regexp.new(listen_include)
        allowed = call.destination_number =~ match || call.caller_id_number =~ match || call.username =~ match
      end
      return allowed unless listen_exclude
      match = Regexp.new(listen_exclude)
      call.destination_number !~ match && call.caller_id_number !~ match && call.username !~ match
    end
  end
end
