class Lead
  include Mongoid::Document

  field :full_name, type: String
  field :email, type: String
  field :date_of_birth, type: Date
  field :address, type: Hash


  validates :full_name, presence: true
  validates :email, presence: true
  validates_format_of :email, with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/
  validates :date_of_birth, presence: true
  validates_format_of :date_of_birth, with: /\A\d{4}\-\d{2}\-\d{2}\Z/
  validate :validate_address

  def validate_address
    errors.add(:address, 'street cannot be blank') if address['street'] == ''
    errors.add(:address, 'city cannot be blank') if address['city'] == ''
    errors.add(:address, 'state cannot be blank') if address['state'] == ''
    errors.add(:address, 'zip code cannot be blank') if address['zip_code'] == ''
  end

  def self.parmitted_params?(json_params)
    json_params.keys.sort == ["address", "date_of_birth", "email", "full_name"] && json_params["address"].keys.sort == ["city", "state", "street", "zip_code"]
  end
end