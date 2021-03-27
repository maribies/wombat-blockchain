require 'digest'
require 'json'

class Blockchain
  def initialize(chain: [], current_transactions: [])
    @chain = chain
    @current_transactions = current_transactions
    self.new_block previous_hash: 1, proof: 100
  end

  def new_block(previous_hash: nil, proof:)
    block = {
      index:          self.chain.length + 1,
      timestamp:      Time.now.to_f,
      transactions:   self.current_transactions,
      proof:          proof,
      previous_hash:  previous_hash || self.hash(self.last_block),
    }
    @current_transactions = []
    self.chain << block
    block
  end

  def new_transaction(sender, recipient, amount)
    self.current_transactions << {
      sender:     sender,
      recipient:  recipient,
      amount:     amount,
    }

    self.last_block[:index] + 1
  end

  def hash(block)
    # Hashes a Block
  end

  def last_block()
    self.chain.last
  end

  def hash(block)
    block_string = JSON.dump(block.sort.to_h)
    Digest::SHA256.hexdigest block_string
  end

  # Simple Proof of Work Algorithm:
  #  - Find a number p' such that hash(pp') contains leading 4 zeroes, where p is the previous p'
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

  attr_reader  :chain, :current_transactions
  private
end
