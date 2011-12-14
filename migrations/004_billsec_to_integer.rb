Class.new Sequel::Migration do

  def up
    alter_table :calls do
      add_column :billsec_s, String
    end
    uds = TinyCdr.db["UPDATE calls SET billsec_s = billsec"]
    uds.update
    alter_table :calls do
      drop_column :billsec
      add_column :billsec, Integer
    end
    uds = TinyCdr.db["UPDATE calls SET billsec = billsec_s::text::integer"]
    uds.update
    alter_table :calls do
      drop_column :billsec_s
    end
  end

  def down
    alter_table :calls do
      add_column :billsec_s, String
    end
    uds = TinyCdr.db["UPDATE calls SET billsec_s = billsec::text"]
    uds.update
    alter_table :calls do
      drop_column :billsec
      add_column :billsec, String
    end
    uds = TinyCdr.db["UPDATE calls SET billsec = billsec_s"]
    uds.update
    alter_table :calls do
      drop_column :billsec_s
    end
  end

end
