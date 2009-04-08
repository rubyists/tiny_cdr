require 'sequel'

class CallsTable < Sequel::Migration
  def up
    create_table :calls do 
      primary_key :id
      varchar :username, :size => 32
      varchar :caller_id_number, :size => 32
      varchar :caller_id_name, :size => 32
      varchar :destination_number, :size => 32, :null => false
      varchar :channel, :null => false
      varchar :context, :null => false
      datetime :start_stamp, :null => false
      datetime :end_stamp, :null => false
      varchar :duration, :size => 12
      varchar :billsec, :size => 12
    end
  end

  def down
    drop_table :calls if DB.table_exists?(:calls)
  end
end
