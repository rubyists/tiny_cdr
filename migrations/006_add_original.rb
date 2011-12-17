Class.new Sequel::Migration do
  def up
    alter_table :calls do
      add_column :leg, :varchar, size: 1
      add_column :original, :xml
      add_column :uuid, :uuid
      add_index  :uuid, :unique => true
    end
  end

  def down
    alter_table :calls do
      drop_column :leg
      drop_column :original
      drop_column :uuid
    end
  end
end
