class CreateWebsites < ActiveRecord::Migration
  def change
    create_table :websites do |t|
      t.string :website, limit: 50
      t.references :ofac_sdn_individual, index: true

      t.timestamps
    end
  end
end
