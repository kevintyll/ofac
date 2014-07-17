class DropOfacSdns < ActiveRecord::Migration
  def change
    drop_table :ofac_sdns
  end
end
