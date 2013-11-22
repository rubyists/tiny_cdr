require 'sequel'

Class.new Sequel::Migration do
  def up
    create_table :managers do 
      primary_key :id
      String :view_include
      String :view_exclude
      String :listen_include
      String :listen_exclude
      Boolean :view_all
      Boolean :listen_all
      foreign_key :account_id, :references => :accounts
    end
  end

  def down
    drop_table :managers if DB.table_exists?(:managers)
  end
end
