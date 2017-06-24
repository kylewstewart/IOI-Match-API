class CreatePrincipals < ActiveRecord::Migration[5.1]
  def change
    create_table :principals do |t|
      t.string :name
      t.string :password_digest


      t.timestamps
    end
  end
end
