class CreateOfacSdnIndividuals < ActiveRecord::Migration
  def change
    create_table :ofac_sdn_individuals do |t|
      t.string :last_name, limit: 50
      t.string :first_name_1, limit: 25
      t.string :first_name_2, limit: 25
      t.string :first_name_3, limit: 25
      t.string :first_name_4, limit: 25
      t.string :first_name_5, limit: 25
      t.string :first_name_6, limit: 25
      t.string :first_name_7, limit: 25
      t.string :first_name_8, limit: 25
      t.string :alternate_last_name, limit: 50
      t.string :alternate_first_name_1, limit: 25
      t.string :alternate_first_name_2, limit: 25
      t.string :alternate_first_name_3, limit: 25
      t.string :alternate_first_name_4, limit: 25
      t.string :alternate_first_name_5, limit: 25
      t.string :alternate_first_name_6, limit: 25
      t.string :alternate_first_name_7, limit: 25
      t.string :alternate_first_name_8, limit: 25
      t.string :address
      t.string :city
      t.timestamps
    end
    # mysql can not have more than 16 parts to an index, so not including first_name_8 and alternate_name_8 in the index
    add_index :ofac_sdn_individuals, [:last_name, :first_name_1, :first_name_2, :first_name_3, :first_name_4, :first_name_5, :first_name_6, :first_name_7, :alternate_last_name, :alternate_first_name_1, :alternate_first_name_2, :alternate_first_name_3, :alternate_first_name_4, :alternate_first_name_5, :alternate_first_name_6, :alternate_first_name_7], name: 'ofac_sdn_individuals_names'

    reversible do |direction|
      direction.up { OfacSdnIndividualLoader.load_current_sdn_file }
    end
  end
end
