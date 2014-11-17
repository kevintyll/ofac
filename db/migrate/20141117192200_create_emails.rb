class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :email, limit: 50
      t.reference :ofac_sdn_individual, index: true

      t.timestamps
    end
  end
end
