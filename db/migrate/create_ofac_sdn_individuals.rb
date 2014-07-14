class CreateOfacSdnIndividuals < ActiveRecord::Migration

  def self.change
    create_table :ofac_sdn_individuals do |t|
      t.text :last_name
      t.text :first_name_1
      t.text :first_name_2
      t.text :first_name_3
      t.string :sdn_type
      t.text :address
      t.string :city
      t.text :alternate_identity_name
      t.timestamps
    end
    add_index :ofac_sdn_individuals, :sdn_type

    drop_table :ofac_sdns
  end
end