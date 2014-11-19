class CreatePhones < ActiveRecord::Migration
  def change
    create_table :phones do |t|
      t.string :phone, limit: 20
      t.references :ofac_sdn_individual, index: true

      t.timestamps
    end
  end
end
