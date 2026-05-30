class CreateFranchiseOrderingSystem < ActiveRecord::Migration[8.1]
  def change
    create_table :franchises do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.string :owner_email, null: false

      t.timestamps
    end

    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 0
      t.references :franchise, foreign_key: true

      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :products do |t|
      t.string :name, null: false
      t.string :category, null: false
      t.integer :unit_price, null: false
      t.integer :stock, null: false, default: 0
      t.string :unit, null: false, default: "개"
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    create_table :orders do |t|
      t.references :franchise, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.integer :total_amount, null: false, default: 0

      t.timestamps
    end

    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.integer :unit_price, null: false

      t.timestamps
    end
  end
end
