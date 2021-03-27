require 'json'
require 'sinatra/base'
require 'securerandom'
require 'blockchain'

class Blockchain
  class App < Sinatra::Base
    BLOCKCHAIN = Blockchain.new()
    NODE_IDENTIFIER = SecureRandom.uuid.delete('-')

    set :default_content_type, 'application/json'

    private def request_body
      @request_body ||= request.body.read
    end

    private def request_data
      @request_data ||= JSON.parse request_body, symbolize_names: true
    end

    get '/mine' do
      "We'll mine a new Block"
    end

    post '/transactions/new' do
      required = [:sender, :recipient, :amount]
      halt 400, 'Missing values' unless required.all? { |k| request_data.key? k }

      index = BLOCKCHAIN.new_transaction(
        sender:     request_data[:sender],
        recipient:  request_data[:recipient],
        amount:     request_data[:amount],
      )

      halt 201, JSON.dump({ message: "Transaction will be added to Block #{index}" })
    end

    get '/chain' do
      response = {
        chain:  BLOCKCHAIN.chain,
        length: BLOCKCHAIN.chain.length,
      }
      JSON.dump(response)
    end
  end
end
