class CreateIois < ActiveRecord::Migration[5.1]
  def change
    create_table :iois do |t|
      t.integer :principal_id
      t.integer :stock_id
      t.string  :side
      t.text    :ranked_principal_ids, array:true, default: []
      t.boolean :active
      t.timestamps
    end
  end
end
