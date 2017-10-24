class LeadSerializer
  def initialize(lead)
    @lead = lead
  end

  def as_json(*)
    data = {
      id: @lead.id.to_s,
      full_name: @lead.full_name,
      email: @lead.email,
      address: @lead.address
    }
    data[:errors] = @lead.errors if @lead.errors.any?
    data
  end
end