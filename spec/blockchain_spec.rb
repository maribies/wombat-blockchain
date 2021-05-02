require 'spec_helper'

RSpec.describe Blockchain do
  def blockchain_for(chain: [], difficulty: 0)
    described_class.new(chain: chain, difficulty: difficulty)
  end

  let(:default_blockchain) { blockchain_for chain: [] }

  describe 'viewing the chain'

  describe 'genesis block' do
    let(:block) { default_blockchain[0] }
    it('has an index of 0') { expect(block[:index]).to eq 0 }
    it('has a timestamp of now') do
      expect(block[:timestamp]).to be_within(1).of(Time.now.to_f)
    end
    it('has no transactions') { expect(block[:transactions]).to eq [] }
    it('has a proof of 0') { expect(block[:proof]).to eq 0 }
    it('has a previous_hash of 0') { expect(block[:previous_hash]).to eq 0 }
  end

  describe 'mining' do
    let(:miner_address) { 'TEST-MINER-ADDRESS' }
    let(:txn1) { { sender: 'TXN1-TEST-SENDER', recipient: 'TXN1-TEST-RECIPIENT', amount: 11 } }
    let(:txn2) { { sender: 'TXN2-TEST-SENDER', recipient: 'TXN2-TEST-RECIPIENT', amount: 22 } }
    let(:pending_transactions) { [txn1, txn2] }
    let(:blockchain) { blockchain_for chain: [] }
    let(:block) { blockchain.mine_block miner: miner_address, transactions: pending_transactions }

    it 'rewards the miner 1 currency from the address "0"' do
      expect(block[:transactions]).to include({
        sender:    "0",
        recipient: miner_address,
        amount:    1
      })
    end

    it 'does the work' do
      expect(block[:proof]).to be_an Integer
    end

    it 'adds a new block to the chain' do
      prev_size = blockchain.size
      block
      expect(blockchain.size).to eq prev_size+1
    end

    describe 'the added block' do
      it 'knows its index' do
        expect(blockchain[block[:index]]).to eq block
        expect(block[:index]).to eq blockchain.size-1
      end

      it 'was created now' do
        expect(block[:timestamp]).to be_within(1).of(Time.now.to_f)
      end

      it 'contains the list of transactions' do
        pending_transactions.each do |txn|
          expect(block[:transactions]).to include txn
        end
      end

      it 'contains a valid proof' do
        prev_proof = blockchain[block[:index]-1][:proof]
        crnt_proof = block[:proof]
        valid      = blockchain.valid_proof? prev_proof, crnt_proof
        expect(valid).to eq true
      end

      it 'contains the hash of the previous block' do
        prev_hash = blockchain.hash_for blockchain[block[:index]-1]
        expect(block[:previous_hash]).to eq prev_hash
      end
    end

    describe 'the work' do
      def assert_proof!(difficulty:, starts_with: nil, doesnt_start_with: nil)
        proof = blockchain_for(difficulty: difficulty).proof_of_work(123)
        hash  = Digest::SHA256.hexdigest("123#{proof}")
        expect(hash).to start_with starts_with if starts_with
        expect(hash).to_not start_with doesnt_start_with if doesnt_start_with
      end

      it 'is a hash with a number of leading zeros that match the specified difficulty' do
        assert_proof! difficulty: 1, starts_with: '0'
        assert_proof! difficulty: 2, starts_with: '00'
        assert_proof! difficulty: 3, starts_with: '000'
        assert_proof! difficulty: 0, doesnt_start_with: '000'
      end

      it 'is a SHA256 hash of the previous proof and the nonce (FIXME: THIS MEANS YOU CAN REWRITE THE CHAIN)' do
        proof = blockchain_for(difficulty: 2).proof_of_work(123)
        expect(Digest::SHA256.hexdigest("123#{proof}")).to start_with '00'
      end
    end
  end
end
