Class.new Sequel::Migration do
  def up
    alter_table :calls do
      add_column :couch_id, String
      add_index  :couch_id, :unique => true
    end
  end

  def down
    alter_table :calls do
      drop_column :couch_id
    end
  end
end
