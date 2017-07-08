class CreateNegotiationPrincipals < ActiveRecord::Migration[5.1]
  def change
    create_table :negotiation_principals do |t|
      t.integer :negotiation_id
      t.integer :principal_id
      t.string :side
      t.integer :satisfaction
      t.boolean :traded

      t.timestamps
    end
  end
end
