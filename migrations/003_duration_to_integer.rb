Class.new Sequel::Migration do

  def up
    alter_table :calls do
      add_column :duration_s, String
    end
    uds = DB["UPDATE calls SET duration_s = duration"]
    uds.update
    alter_table :calls do
      drop_column :duration
      add_column :duration, Integer
    end
    uds = DB["UPDATE calls SET duration = duration_s::text::integer"]
    uds.update
    alter_table :calls do
      drop_column :duration_s
    end
  end

  def down
    alter_table :calls do
      add_column :duration_s, String
    end
    uds = DB["UPDATE calls SET duration_s = duration::text"]
    uds.update
    alter_table :calls do
      drop_column :duration
      add_column :duration, String
    end
    uds = DB["UPDATE calls SET duration = duration_s"]
    uds.update
    alter_table :calls do
      drop_column :duration_s
    end
  end

end
