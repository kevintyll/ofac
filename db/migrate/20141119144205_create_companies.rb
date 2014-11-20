class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name, limit: 50
      t.references :ofac_sdn_individual

      t.timestamps
    end
  end
end
