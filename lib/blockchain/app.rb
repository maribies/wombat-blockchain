require 'json'
require 'sinatra/base'
require 'sinatra/reloader'
require 'securerandom'
require 'sinatra/flash'
require 'blockchain'
require 'blockchain/resolver'

class Blockchain
  class App < Sinatra::Base
    configure :development do
      register Sinatra::Reloader
      after_reload do
        puts 'reloaded'
      end
    end

    # `||=` b/c of the reloader
    DIFFICULTY           ||= 4
    RESOLVER             ||= Blockchain::Resolver.new difficulty: DIFFICULTY
    BLOCKCHAIN           ||= Blockchain.new chain: [], difficulty: DIFFICULTY
    PENDING_TRANSACTIONS ||= []
    NODE_IDENTIFIER      ||= SecureRandom.uuid.delete('-')

    set :default_content_type, 'application/json'
    set :erb, layout: :layout

    enable :sessions
    register Sinatra::Flash

    private def request_body
      @request_body ||= request.body.read
    end

    private def request_data
      # form via website ui
      @request_data ||= if request.content_type == "application/x-www-form-urlencoded"
        params[:transaction]
      else
        # request via api
        JSON.parse request_body, symbolize_names: true
      end
    end

    get '/', :provides => 'html' do
      erb :index
    end

    get '/mine' do
      # We must receive a reward for finding the proof.
      # The sender is "0" to signify that this node has mined a new coin.
      block = BLOCKCHAIN.mine_block(
        miner: NODE_IDENTIFIER,
        transactions: PENDING_TRANSACTIONS,
      )

      PENDING_TRANSACTIONS.clear

      halt 200, JSON.dump({
        message:       "New Block Forged",
        index:         block[:index],
        transactions:  block[:transactions],
        proof:         block[:proof],
        previous_hash: block[:previous_hash],
      })
    end

    private def accepts_html?
      request.accept.any? { |mimetype| mimetype.to_s == 'text/html' }
    end

    # Maybe instead of posting to a new url, redirect and show success message in a model?
    # Or make this whole page have information about what was done and maybe a cool graphic/eventually animation?
    post '/transactions/new' do
      required = [:sender, :recipient, :amount]
      halt 400, 'Missing values' unless required.all? { |k| request_data.key? k }

      PENDING_TRANSACTIONS << {
        sender:    request_data[:sender],
        recipient: request_data[:recipient],
        amount:    request_data[:amount],
      }

      index = BLOCKCHAIN.size + 1

      if accepts_html?
        flash[:success] = "You have successfully made a transaction."
        redirect('/')
      else
        halt 201, JSON.dump({ message: "Transaction will be added to Block #{index}" })
      end
    end

    get '/chain' do
      halt 200, JSON.dump({
        length: BLOCKCHAIN.chain.length,
        chain:  BLOCKCHAIN.chain,
      })
    end

    post '/nodes' do
      nodes = request_data[:nodes]
      nodes.nil? and halt 400, { error: 'Please supply a valid list of nodes' }

      nodes.each { |node| RESOLVER.register_node node }

      halt 201, JSON.dump(
        message: 'New nodes have been added',
        total_nodes: RESOLVER.nodes.to_a,
      )
    end


    get '/nodes/resolve' do
      chain = RESOLVER.resolve_conflicts
      message = 'Our chain is authoritative'
      if chain && chain.size > BLOCKCHAIN.size
        BLOCKCHAIN.chain = chain
        message = 'Our chain was replaced'
      end
      halt 200, JSON.dump(new_chain: BLOCKCHAIN.chain, message: message)
    end
  end
end
