require 'json'
require 'sinatra/base'
require 'blockchain'

class Blockchain
  class App < Sinatra::Base
    BLOCKCHAIN = Blockchain.new()

    get '/mine' do
      "We'll mine a new Block"
    end

    post '/transactions/new' do
      "We'll add a new transaction"
    end

    get '/chain' do
      response = {
        chain: BLOCKCHAIN.chain,
        length: BLOCKCHAIN.chain.length,
      }
      JSON.dump(response)
    end
  end
end
