class CreateInventorySystem < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :reorder_point, :integer, null: false, default: 10

    create_table :stock_receipts do |t|
      t.date :received_on, null: false
      t.string :supplier
      t.text :note
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    create_table :stock_receipt_lines do |t|
      t.references :stock_receipt, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false

      t.timestamps
    end

    create_table :stock_movements do |t|
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.integer :movement_type, null: false
      t.string :reference_type
      t.bigint :reference_id
      t.text :note
      t.integer :balance_after, null: false

      t.timestamps
    end

    add_index :stock_movements, %i[reference_type reference_id]
    add_index :stock_movements, %i[product_id created_at]
  end
end
