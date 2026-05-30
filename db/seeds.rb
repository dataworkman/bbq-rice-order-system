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
  ["Downtown LA", "123 Main St, Los Angeles, CA 90012", "owner1@example.com"],
  ["Hollywood", "456 Sunset Blvd, Los Angeles, CA 90028", "owner2@example.com"],
  ["Santa Monica", "789 Ocean Ave, Santa Monica, CA 90401", "owner3@example.com"],
  ["Pasadena", "12 Colorado Blvd, Pasadena, CA 91105", "owner4@example.com"],
  ["Long Beach", "56 Pine Ave, Long Beach, CA 90802", "owner5@example.com"],
  ["San Diego", "78 Harbor Dr, San Diego, CA 92101", "owner6@example.com"],
  ["Irvine", "90 Spectrum Center Dr, Irvine, CA 92618", "owner7@example.com"],
  ["Anaheim", "34 Katella Ave, Anaheim, CA 92802", "owner8@example.com"],
  ["Burbank", "11 Olive Ave, Burbank, CA 91502", "owner9@example.com"],
  ["Torrance", "200 Torrance Blvd, Torrance, CA 90503", "owner10@example.com"]
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
products = [
  ["Burger Bun", "Buns & Rolls", 45, 500, "ea"],
  ["Chicken Patty", "Patties", 120, 200, "ea"],
  ["Beef Patty", "Patties", 150, 150, "ea"],
  ["Frozen French Fries", "Fries", 4800, 80, "box"],
  ["Cheese Slice", "Cheese", 8, 0, "slice"],
  ["Romaine Lettuce", "Produce", 450, 40, "lb"],
  ["Tomato", "Produce", 550, 35, "lb"],
  ["Cola Syrup", "Beverages", 12_000, 25, "gal"],
  ["Ketchup", "Sauces", 550, 60, "jug"],
  ["Mustard", "Sauces", 480, 55, "jug"],
  ["Paper Cups (L)", "Packaging", 1500, 100, "box"],
  ["Napkins", "Packaging", 800, 70, "box"]
]

puts "Creating products..."
products.each do |name, category, price_cents, stock, unit|
  Product.create!(
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
