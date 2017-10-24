require 'sinatra'
require 'sinatra/namespace'
require 'mongoid'
require './model/lead.rb'
require './model/client.rb'
require './model/serializer/lead.rb'

# DB Setup
Mongoid.load! "mongoid.config"

#end points
namespace '/api/v1' do
  before do
    content_type 'application/json'
    pass if ['auth'].include? request.path_info.split('/')[3]
    client = Client.find_by(token: env['HTTP_AUTHORIZATION']) rescue nil unless env['HTTP_AUTHORIZATION'].nil?
    unless client.present? && client.valid_till > Time.now
      halt 401, { message:'Unauthorized.' }.to_json
    end
  end

  helpers do
    def json_params
      begin
        JSON.parse(request.body.read)
      rescue
        halt 400, { message:'Invalid JSON.' }.to_json
      end
    end

    def serialize(lead)
      LeadSerializer.new(lead).to_json
    end
  end

  post '/leads' do
    params = json_params
    if Lead.parmitted_params?(params)
      lead = Lead.new(params)
      halt 422, serialize(lead) unless lead.save
      status 201
    else
      halt 400, { message:'Invalid params.' }.to_json
    end
  end

  post '/auth' do
    if env['HTTP_CLIENT_ID'] && env['HTTP_CLIENT_SECRET']
      client = Client.find_by(client_id: env['HTTP_CLIENT_ID'], secret: env['HTTP_CLIENT_SECRET']) rescue nil
      if client.present?
        client.refrest_token
        halt 201, {token: client.token}.to_json
      end
    end
    halt 401, { message:'Unauthorized.' }.to_json
  end
end 

