require 'innate'

module TinyCdr
  include Innate::Optioned

  options.dsl do
    o "Postgres Database Name", :pg_dbname, ENV["TinyCdr_PgDB"] || "tiny_cdr"

    o "Couch Database URI", :couch_uri, ENV["TinyCdr_CouchURI"]

    o "Log Level (DEBUG, INFO, WARN, ERROR, CRIT)", :log_level,
      ENV["TinyCdr_LogLevel"] || "INFO"

    o "Main Recording Path", :base_record_path, ENV["TinyCdr_BaseRecordPath"] || "/var/spool/freeswitch/recordings"

    o "Archive Recording Paths (: separated, unix-style)", :archive_record_paths, ENV["TinyCdr_ArchiveRecordPaths"] || "/mnt/recordings"

    o "Mounted Recording Path", :mounted_record_path, ENV["TinyCdr_MountedRecordPath"] || "/mnt/recordings"

    o "Temporary Audio File Path", :tmp_file_path, ENV["TinyCdr_TmpFilePath"] || "/tmp"
  end
end
