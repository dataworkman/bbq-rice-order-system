class AddItemNumberToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :item_number, :string
    add_column :order_items, :item_number, :string

    reversible do |dir|
      dir.up do
        Product.reset_column_information
        Product.find_each.with_index(1) do |product, index|
          product.update_column(:item_number, format("ITM-%03d", index))
        end

        OrderItem.reset_column_information
        OrderItem.find_each do |order_item|
          number = order_item.product&.item_number
          order_item.update_column(:item_number, number) if number.present?
        end
      end
    end

    change_column_null :products, :item_number, false
    add_index :products, :item_number, unique: true
  end
end
