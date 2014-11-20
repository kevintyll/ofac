class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :email, limit: 50
      t.references :ofac_sdn_individual

      t.timestamps
    end
  end
end
