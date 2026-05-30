class PasswordResetter
  def self.reset!(user)
    password = InitialPassword.generate
    user.update!(password: password, password_confirmation: password)
    password
  end
end
