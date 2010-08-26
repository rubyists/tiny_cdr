require 'sequel'

Class.new Sequel::Migration do
  def up
    create_table :calls do 
      primary_key :id
      String :username
      String :caller_id_number
      String :caller_id_name
      String :destination_number, :null => false
      String :channel, :null => false
      String :context, :null => false
      DateTime :start_stamp, :null => false
      DateTime :end_stamp, :null => false
      String :duration, :size => 12
      String :billsec, :size => 12
    end
  end

  def down
    drop_table :calls if DB.table_exists?(:calls)
  end
end
