module InitialPassword
  module_function

  def generate(length = 10)
    SecureRandom.alphanumeric(length)
  end
end
