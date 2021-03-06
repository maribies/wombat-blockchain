require 'digest'
require 'json'

class Blockchain
  module Helpers
    def valid_proof?(last_proof, proof, difficulty)
      guess = "#{last_proof}#{proof}"
      guess_hash = Digest::SHA256.hexdigest guess
      guess_hash[0...difficulty] == "0"*difficulty
    end

    def hash_for(block)
      Digest::SHA256.hexdigest JSON.dump(block.sort.to_h)
    end
  end

  include Helpers

  # accessor for now so we can swap it out if a neighbour has a longer blockchain
  # b/c we saved it in a constant on the app, we don't have a convenient way of swapping out Blockchain instances
  attr_accessor :chain

  attr_reader :difficulty

  def initialize(chain:, difficulty: 4)
    @difficulty = difficulty
    @chain = chain
    @chain << new_block(previous_hash: 0, proof: 0, transactions: []) # FIXME this only makes sense when chain is empty
  end

  def [](index)
    @chain.fetch index
  end

  def size
    @chain.size
  end

  def mine_block(miner:, transactions:)
    @chain << new_block(
      proof: proof_of_work(last_block[:proof]),
      previous_hash: hash_for(last_block),
      transactions: [
        *transactions,
        { sender: "0", recipient: miner, amount: 1 }, # Reward the miner for doing the work
      ],
    )
    @chain.last
  end


  def last_block()
    self.chain.last
  end

  # Simple Proof of Work Algorithm:
  #  - Find a number p' such that hash_for(pp') contains leading 4 zeroes, where p is the previous p'
  #  - p is the previous proof, and p' is the new proof
  def proof_of_work(last_proof)
    proof = 0
    proof += 1 until self.valid_proof?(last_proof, proof, @difficulty)
    proof
  end

  private

  def new_block(previous_hash:, proof:, transactions:)
    { index:          self.chain.length,
      timestamp:      Time.now.to_f,
      transactions:   transactions,
      proof:          proof,
      previous_hash:  previous_hash || self.hash_for(self.last_block),
    }
  end
end
