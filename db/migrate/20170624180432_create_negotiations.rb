class CreateNegotiations < ActiveRecord::Migration[5.1]
  def change
    create_table :negotiations do |t|
      t.integer :agent_id
      t.boolean :active
      t.boolean :traded

      t.timestamps
    end
  end
end
