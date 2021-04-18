require 'digest'
require 'json'
require 'set'
require 'uri'
require 'net/http'

class Blockchain
  def initialize(chain:, pending_transactions:[])
    @chain = chain
    @pending_transactions = pending_transactions
    @nodes = Set.new
    self.add_block previous_hash: 0, proof: 0
  end

  def [](index)
    @chain.fetch index
  end

  def mine_block(miner:)
    # Reward the miner for doing the work
    add_transaction(
      sender:    "0",
      recipient: miner,
      amount:    1,
    )

    # Forge the new Block by adding it to the chain
    proof = proof_of_work last_block[:proof]
    add_block(
      proof: proof,
      previous_hash: hash_for(last_block),
    )
  end


  def add_transaction(sender:, recipient:, amount:)
    self.pending_transactions << {
      sender:     sender,
      recipient:  recipient,
      amount:     amount,
    }

    self.last_block[:index] + 1
  end

  def last_block()
    self.chain.last
  end

  def hash_for(block)
    Digest::SHA256.hexdigest JSON.dump(block.sort.to_h)
  end

  # Simple Proof of Work Algorithm:
  #  - Find a number p' such that hash_for(pp') contains leading 4 zeroes, where p is the previous p'
  #  - p is the previous proof, and p' is the new proof
  def proof_of_work(last_proof)
    proof = 0
    proof += 1 until self.valid_proof?(last_proof, proof)
    proof
  end

  def valid_proof?(last_proof, proof)
    guess = "#{last_proof}#{proof}"
    guess_hash = Digest::SHA256.hexdigest guess
    guess_hash[0...4] == "0000"
  end

  def valid_chain?(chain)
    chain.each_cons 2 do |prev, crnt|
      return false unless crnt.fetch(:previous_hash) == hash_for(prev)
      return false unless valid_proof? prev.fetch(:proof), crnt.fetch(:proof)
    end
    true
  end


  # Eg. register_node('http://192.168.0.5:5000')
  def register_node(address)
    nodes.add URI address
  end

  # This is our Consensus Algorithm, it resolves conflicts
  # by replacing our chain with the longest one in the network.
  # :return: <bool> True if our chain was replaced, False if not
  def resolve_conflicts
    longest_neighbour_chain = nodes
      .filter_map { |node| Net::HTTP.get_response node rescue nil }
      .select { |response| response.code == '200' }
      .filter_map { |resp| JSON.parse(resp.body, symbolize_names: true)[:chain] }
      .select { |chain| valid_chain? chain }
      .max_by(&:size)

    return false if longest_neighbour_chain.size <= chain.size
    @chain = new_chain
    true
  end


  attr_reader :nodes, :chain, :pending_transactions

  private

  def add_block(previous_hash:, proof:)
    block = {
      index:          self.chain.length,
      timestamp:      Time.now.to_f,
      transactions:   self.pending_transactions,
      proof:          proof,
      previous_hash:  previous_hash || self.hash_for(self.last_block),
    }
    @pending_transactions = []
    self.chain << block
    block
  end


  # def normalize_address(address)
  #   uri = URI.parse address
  #   normalized = ""
  #   normalized << uri.userinfo << "@" if uri.userinfo
  #   normalized << uri.host
  #   normalized << ":" << uri.port.to_s if uri.port != uri.default_port
  #   normalized
  # end
end
