# frozen_string_literal: true

password = "password123"

puts "Resetting data..."
OrderItem.delete_all
Order.delete_all
Product.delete_all
User.where(role: :owner).delete_all
Franchise.delete_all

puts "Creating admin user..."
User.find_or_create_by!(email: "admin@hq.com") do |user|
  user.password = password
  user.password_confirmation = password
  user.role = :admin
end

franchise_data = [
  [ "Downtown LA", "123 Main St, Los Angeles, CA 90012", "owner1@example.com" ],
  [ "Hollywood", "456 Sunset Blvd, Los Angeles, CA 90028", "owner2@example.com" ],
  [ "Santa Monica", "789 Ocean Ave, Santa Monica, CA 90401", "owner3@example.com" ],
  [ "Pasadena", "12 Colorado Blvd, Pasadena, CA 91105", "owner4@example.com" ],
  [ "Long Beach", "56 Pine Ave, Long Beach, CA 90802", "owner5@example.com" ],
  [ "San Diego", "78 Harbor Dr, San Diego, CA 92101", "owner6@example.com" ],
  [ "Irvine", "90 Spectrum Center Dr, Irvine, CA 92618", "owner7@example.com" ],
  [ "Anaheim", "34 Katella Ave, Anaheim, CA 92802", "owner8@example.com" ],
  [ "Burbank", "11 Olive Ave, Burbank, CA 91502", "owner9@example.com" ],
  [ "Torrance", "200 Torrance Blvd, Torrance, CA 90503", "owner10@example.com" ]
]

puts "Creating #{franchise_data.size} franchisees..."
franchise_data.each do |name, address, email|
  franchise = Franchise.create!(name: name, address: address, owner_email: email)

  User.create!(
    email: email,
    password: password,
    password_confirmation: password,
    role: :owner,
    franchise: franchise
  )
end

# unit_price is stored in cents (e.g. 45 = $0.45)
# [item_number, name, category, price_cents, stock, unit]
products = [
  [ "BUN-001", "Burger Bun", "Buns & Rolls", 45, 500, "ea" ],
  [ "PAT-001", "Chicken Patty", "Patties", 120, 200, "ea" ],
  [ "PAT-002", "Beef Patty", "Patties", 150, 150, "ea" ],
  [ "FRI-001", "Frozen French Fries", "Fries", 4800, 80, "box" ],
  [ "CHE-001", "Cheese Slice", "Cheese", 8, 0, "slice" ],
  [ "PRO-001", "Romaine Lettuce", "Produce", 450, 40, "lb" ],
  [ "PRO-002", "Tomato", "Produce", 550, 35, "lb" ],
  [ "BEV-001", "Cola Syrup", "Beverages", 12_000, 25, "gal" ],
  [ "SAU-001", "Ketchup", "Sauces", 550, 60, "jug" ],
  [ "SAU-002", "Mustard", "Sauces", 480, 55, "jug" ],
  [ "PKG-001", "Paper Cups (L)", "Packaging", 1500, 100, "box" ],
  [ "PKG-002", "Napkins", "Packaging", 800, 70, "box" ]
]

puts "Creating products..."
products.each do |item_number, name, category, price_cents, stock, unit|
  Product.create!(
    item_number: item_number,
    name: name,
    category: category,
    unit_price: price_cents,
    stock: stock,
    unit: unit,
    active: true
  )
end

puts "Seed complete!"
puts "Admin: admin@hq.com / #{password}"
puts "Owners: owner1@example.com ~ owner10@example.com / #{password}"
puts "Prices are stored in USD cents (e.g. 45 = $0.45)"
