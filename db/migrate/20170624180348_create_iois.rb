class CreateIois < ActiveRecord::Migration[5.1]
  def change
    create_table :iois do |t|
      t.integer :principal_id
      t.string  :stock
      t.string  :side
      t.text    :ranked_eps, array:true, default: []
      t.boolean :active
      t.timestamps
    end
  end
end
