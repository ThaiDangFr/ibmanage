class CreatePositions < ActiveRecord::Migration[5.2]
  def change
    create_table :positions do |t|
      t.string :ticker
      t.integer :quantity
      t.float :cost
      t.references :portfolio, foreign_key: true

      t.timestamps
    end
  end
end
