class CreateSponsorships < ActiveRecord::Migration[5.1]
  def change
    create_table :sponsorships do |t|
      t.integer :principal_id
      t.integer :agent_id

      t.timestamps
    end
  end
end
