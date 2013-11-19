require 'innate'

module TinyCdr
  include Innate::Optioned

  options.dsl do
    o "Postgres Database Name", :pg_dbname, ENV["TinyCdr_PgDB"] || "tiny_cdr"

    o "Couch Database URI", :couch_uri, ENV["TinyCdr_CouchURI"]

    o "Log Level (DEBUG, INFO, WARN, ERROR, CRIT)", :log_level,
      ENV["TinyCdr_LogLevel"] || "INFO"

    o "Main Recording Path", :base_record_path, ENV["TinyCdr_BaseRecordPath"] || "/var/spool/freeswitch/recordings"

    o "Archive Recording Path", :archive_record_path, ENV["TinyCdr_ArchiveRecordPath"] || "/mnt/recordings"

    o "Mounted Recording Path", :mounted_record_path, ENV["TinyCdr_MountedRecordPath"] || "/mnt/recordings"
  end
end
