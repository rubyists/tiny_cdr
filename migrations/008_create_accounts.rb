require 'sequel'

Class.new Sequel::Migration do
  def up
    create_table :accounts do 
      primary_key :id
      String :username, :null => false
      String :email
      String :extension, :null => false
      String :salt
      String :crypted_password
    end
  end

  def down
    drop_table :accounts if DB.table_exists?(:accounts)
  end
end
