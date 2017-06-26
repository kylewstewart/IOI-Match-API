class CreateNegotiationPrincipals < ActiveRecord::Migration[5.1]
  def change
    create_table :negotiation_principals do |t|
      t.integer :negotiation_id
      t.integer :principal_id

      t.timestamps
    end
  end
end
