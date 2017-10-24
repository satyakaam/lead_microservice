ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require 'json'
require_relative './server.rb'
 
include Rack::Test::Methods
 
def app
  Sinatra::Application
end

describe 'validation tests' do
  it 'should be created with valid data' do
    lead = Lead.new(full_name: 'satyakam parikh', email: 'satyakam@email.com', date_of_birth: '1990-05-20', address: { street: 'my street', city: 'valsad', state: 'GJ', zip_code: '396001'})
    assert lead.valid?
  end

  it 'should not be created when full_name is not given' do
    lead = Lead.new(full_name: '', email: 'satyakam@email.com', date_of_birth: '1990-05-20', address: { street: 'my street', city: 'valsad', state: 'GJ', zip_code: '396001'})
    refute lead.valid?, "can't be blank"
  end

  it 'should not be created when email is not given' do
    lead = Lead.new(full_name: 'satyakam parikh', email: '', date_of_birth: '1990-05-20', address: { street: 'my street', city: 'valsad', state: 'GJ', zip_code: '396001'})
    refute lead.valid?, "can't be blank"
  end

  it 'should not be created when date_of_birth is not given' do
    lead = Lead.new(full_name: 'satyakam parikh', email: '', date_of_birth: '', address: { street: 'my street', city: 'valsad', state: 'GJ', zip_code: '396001'})
    refute lead.valid?, "can't be blank"
  end

  it 'should not be created when address[:street] is not given' do
    lead = Lead.new(full_name: 'satyakam parikh', email: '', date_of_birth: '1990-05-20', address: { street: '', city: 'valsad', state: 'GJ', zip_code: '396001'})
    refute lead.valid?, "can't be blank"
  end

  it 'should not be created when address[:city] is not given' do
    lead = Lead.new(full_name: 'satyakam parikh', email: '', date_of_birth: '1990-05-20', address: { street: 'my street', city: '', state: 'GJ', zip_code: '396001'})
    refute lead.valid?, "can't be blank"
  end

  it 'should not be created when address[:street] is not given' do
    lead = Lead.new(full_name: 'satyakam parikh', email: '', date_of_birth: '1990-05-20', address: { street: 'my street', city: 'valsad', state: '', zip_code: '396001'})
    refute lead.valid?, "can't be blank"
  end

  it 'should not be created when address[:street] is not given' do
    lead = Lead.new(full_name: 'satyakam parikh', email: '', date_of_birth: '1990-05-20', address: { street: 'my street', city: 'valsad', state: 'GJ', zip_code: ''})
    refute lead.valid?, "can't be blank"
  end
end

describe '/api/v1/leads' do
  it 'should return Unauthorized. without token' do
    post '/api/v1/leads'
    last_response.body.must_equal '{"message":"Unauthorized."}'
  end

  it 'should accept only a valid json' do
    Client.collection.drop
    client = Client.create(client_id: 'id1', secret: 'secret1')
    post '/api/v1/auth', {}, { "HTTP_CLIENT_ID" => "id1", "HTTP_CLIENT_SECRET" => "secret1" }
    data = {full_name: 'satyakam parikh', email: 'satyakam@email.com', date_of_birth: '1990-05-20', address: { street: 'my street', city: 'valsad', state: 'GJ', zip_code: '396001'}}
    post '/api/v1/leads', data, { "HTTP_AUTHORIZATION" => Client.last.token}
    last_response.body.must_equal "{\"message\":\"Invalid JSON.\"}"
  end

  it 'should accept only a valid json with the right params' do
    Client.collection.drop
    client = Client.create(client_id: 'id1', secret: 'secret1')
    post '/api/v1/auth', {}, { "HTTP_CLIENT_ID" => "id1", "HTTP_CLIENT_SECRET" => "secret1" }
    data = {email: 'satyakam@email.com', date_of_birth: '1990-05-20', address: { street: 'my street', city: 'valsad', state: 'GJ', zip_code: '396001'}}
    post '/api/v1/leads', data.to_json, { "HTTP_AUTHORIZATION" => Client.last.token}
    last_response.body.must_equal "{\"message\":\"Invalid params.\"}"
  end

  it 'should save lead with valid token and valid request body' do
    Client.collection.drop
    Lead.collection.drop
    client = Client.create(client_id: 'id1', secret: 'secret1')
    post '/api/v1/auth', {}, { "HTTP_CLIENT_ID" => "id1", "HTTP_CLIENT_SECRET" => "secret1" }
    data = {full_name: 'satyakam parikh', email: 'satyakam@email.com', date_of_birth: '1990-05-20', address: { street: 'my street', city: 'valsad', state: 'GJ', zip_code: '396001'}}
    post '/api/v1/leads', data.to_json, { "HTTP_AUTHORIZATION" => Client.last.token}
    Lead.last.full_name.must_equal data[:full_name]
  end
end

describe '/api/v1/auth' do
  it 'should return a token with valid id and secret' do
    Client.collection.drop
    client1 = Client.create(client_id: 'id1', secret: 'secret1')
    post '/api/v1/auth', {}, { "HTTP_CLIENT_ID" => "id1", "HTTP_CLIENT_SECRET" => "secret1" }
    last_response.body.must_equal "{\"token\":\"#{Client.last.token.to_s}\"}"
  end

  it 'token should be valid for only 30 mins' do
    Client.collection.drop
    client1 = Client.create(client_id: 'id1', secret: 'secret1')
    post '/api/v1/auth', {}, { "HTTP_CLIENT_ID" => "id1", "HTTP_CLIENT_SECRET" => "secret1" }
    Client.last.valid_till.to_s.must_equal (Time.now + 30*60).to_s
  end

  it 'should return Unauthorized. with invalid client' do
    Client.collection.drop
    client1 = Client.create(client_id: 'id1', secret: 'secret1')
    post '/api/v1/auth', {}, { "HTTP_CLIENT_ID" => "idx", "HTTP_CLIENT_SECRET" => "secret1" }
    last_response.body.must_equal '{"message":"Unauthorized."}'
  end
end