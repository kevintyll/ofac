class DropOfacSdns < ActiveRecord::Migration
  def change
    drop_table :ofac_sdns if ActiveRecord::Base.connection.table_exists? 'ofac_sdns'
  end
end
