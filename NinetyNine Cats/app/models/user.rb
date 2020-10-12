# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  username        :string           not null
#  password_digest :string           not null
#  session_token   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class User < ApplicationRecord
  validates :username, :session_token, presence: true, uniqueness: true
  validates :password_digest, presence: true
  validates :password, length: { minimum: 6,}, allow_nil: true

  after_initialize :ensure_session_token
  attr_reader :password

    def reset_session_token!
        self.session_token = self.generate_session_token
        self.save!
        self.session_token
    end

    def self.generate_session_token
        SecureRandom::urlsafe_base64(16)
    end

    def password=(password)
        @password = password
        self.password_digest = BCrypt::Password.create(password) 
    end

    def is_password?(password)
        attempted_pass = BCrypt::Password.new(self.password_digest)
        attempted_pass.is_password?(password)
    end
    
    def self.find_by_credentials(username, password)
        user = User.find_by(username: username)
        return nil unless user && user.is_password?(password)

        user
    end

    def ensure_session_token
        self.session_token ||= self.class.generate_session_token
    end
end

# 1. F: `self.find_by_credentials` (class method)
# 2. I: `is_password?`
# 3. G: `self.generate_session_token` (class method)
# 4. V: validations, `after_initialize`
# 5. A: `attr_reader :password`
# 6. P: `password=`
# 7. E: `ensure_session_token`
# 8. R: `reset_session_token!`
