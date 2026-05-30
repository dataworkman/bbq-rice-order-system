# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_30_140000) do
  create_table "franchises", force: :cascade do |t|
    t.string "address", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "owner_email", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "item_number"
    t.integer "order_id", null: false
    t.integer "product_id", null: false
    t.integer "quantity", null: false
    t.integer "unit_price", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "franchise_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "total_amount", default: 0, null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["franchise_id"], name: "index_orders_on_franchise_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.string "item_number", null: false
    t.string "name", null: false
    t.integer "reorder_point", default: 10, null: false
    t.integer "stock", default: 0, null: false
    t.string "unit", default: "개", null: false
    t.integer "unit_price", null: false
    t.datetime "updated_at", null: false
    t.index ["item_number"], name: "index_products_on_item_number", unique: true
  end

  create_table "stock_movements", force: :cascade do |t|
    t.integer "balance_after", null: false
    t.datetime "created_at", null: false
    t.integer "movement_type", null: false
    t.text "note"
    t.integer "product_id", null: false
    t.integer "quantity", null: false
    t.bigint "reference_id"
    t.string "reference_type"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["product_id", "created_at"], name: "index_stock_movements_on_product_id_and_created_at"
    t.index ["product_id"], name: "index_stock_movements_on_product_id"
    t.index ["reference_type", "reference_id"], name: "index_stock_movements_on_reference_type_and_reference_id"
    t.index ["user_id"], name: "index_stock_movements_on_user_id"
  end

  create_table "stock_receipt_lines", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "product_id", null: false
    t.integer "quantity", null: false
    t.integer "stock_receipt_id", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_stock_receipt_lines_on_product_id"
    t.index ["stock_receipt_id"], name: "index_stock_receipt_lines_on_stock_receipt_id"
  end

  create_table "stock_receipts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "note"
    t.date "received_on", null: false
    t.string "supplier"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_stock_receipts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.integer "franchise_id"
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["franchise_id"], name: "index_users_on_franchise_id"
  end

  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "franchises"
  add_foreign_key "orders", "users"
  add_foreign_key "stock_movements", "products"
  add_foreign_key "stock_movements", "users"
  add_foreign_key "stock_receipt_lines", "products"
  add_foreign_key "stock_receipt_lines", "stock_receipts"
  add_foreign_key "stock_receipts", "users"
  add_foreign_key "users", "franchises"
end
