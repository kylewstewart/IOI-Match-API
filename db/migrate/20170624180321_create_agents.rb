class CreateAgents < ActiveRecord::Migration[5.1]
  def change
    create_table :agents do |t|
      t.string :name
      t.string :password_digest

      t.timestamps
    end
  end
end
