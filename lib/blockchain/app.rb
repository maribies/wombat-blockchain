require 'json'
require 'sinatra/base'
require "sinatra/reloader"
require 'securerandom'
require 'blockchain'

class Blockchain
  class App < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
      after_reload do
        puts 'reloaded'
      end
    end

    BLOCKCHAIN = Blockchain.new()
    NODE_IDENTIFIER = SecureRandom.uuid.delete('-')

    set :default_content_type, 'application/json'
    set :erb, layout: :layout

    private def request_body
      @request_body ||= request.body.read
    end

    private def request_data
      @request_data ||= JSON.parse request_body, symbolize_names: true
    end

    get '/', :provides => 'html' do
      erb :index
    end

    get '/mine' do
      # We must receive a reward for finding the proof.
      # The sender is "0" to signify that this node has mined a new coin.
      BLOCKCHAIN.new_transaction(
        sender:     "0",
        recipient:  NODE_IDENTIFIER,
        amount:     1,
      )

      # Forge the new Block by adding it to the chain
      last  = BLOCKCHAIN.last_block
      block = BLOCKCHAIN.new_block(
        proof: BLOCKCHAIN.proof_of_work(last[:proof]),
        previous_hash: BLOCKCHAIN.hash(last),
      )

      halt 200, JSON.dump({
        message:       "New Block Forged",
        index:         block[:index],
        transactions:  block[:transactions],
        proof:         block[:proof],
        previous_hash: block[:previous_hash],
      })
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
      halt 200, JSON.dump({
        chain:  BLOCKCHAIN.chain,
        length: BLOCKCHAIN.chain.length,
      })
    end
  end
end
