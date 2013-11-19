Class.new Sequel::Migration do
  def up
    alter_table :calls do
      add_column :recording, :varchar
    end
  end

  def down
    alter_table :calls do
      drop_column :recording
    end
  end
end
