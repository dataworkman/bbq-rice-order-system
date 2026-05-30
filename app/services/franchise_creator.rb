class FranchiseCreator
  Result = Data.define(:franchise, :initial_password, :success, :error) do
    def success?
      success
    end
  end

  def self.call(**franchise_attrs)
    new(franchise_attrs).call
  end

  def initialize(franchise_attrs)
    @franchise_attrs = franchise_attrs
  end

  def call
    password = InitialPassword.generate
    franchise = nil

    ActiveRecord::Base.transaction do
      franchise = Franchise.create!(@franchise_attrs)
      User.create!(
        email: franchise.owner_email,
        password: password,
        password_confirmation: password,
        role: :owner,
        franchise: franchise
      )
    end

    Result.new(franchise: franchise, initial_password: password, success: true, error: nil)
  rescue ActiveRecord::RecordInvalid => e
    franchise = build_franchise_from_error(e)
    Result.new(franchise: franchise, initial_password: nil, success: false, error: e)
  end

  private

  def build_franchise_from_error(error)
    if error.record.is_a?(User)
      franchise = Franchise.new(@franchise_attrs)
      error.record.errors.each do |err|
        next unless err.attribute == :email

        franchise.errors.add(:owner_email, err.message)
      end
      franchise
    else
      error.record
    end
  end
end
