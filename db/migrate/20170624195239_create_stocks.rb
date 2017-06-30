class CreateStocks < ActiveRecord::Migration[5.1]
  def change
    create_table :stocks do |t|
      t.string  :name
      t.string  :exch_code
      t.string  :county

      t.timestamps
    end
  end
end
