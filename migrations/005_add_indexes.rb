Class.new Sequel::Migration do
  def up
    alter_table :calls do
      add_index  :caller_id_number
      add_index  :destination_number
      add_index  :username
      add_index  :start_stamp
      add_index  :end_stamp
    end
  end

  def down
    alter_table :calls do
      drop_index  :caller_id_number
      drop_index  :destination_number
      drop_index  :username
      drop_index  :start_stamp
      drop_index  :end_stamp
    end
  end
end
