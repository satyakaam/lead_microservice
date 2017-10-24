class Client
  include Mongoid::Document

  field :client_id, type: String
  field :secret, type: String
  field :token, type: String
  field :valid_till, type: Time

  def refrest_token
    self.token = SecureRandom.hex(10)
    self.valid_till = Time.now + 30*60
    self.save
  end
end
