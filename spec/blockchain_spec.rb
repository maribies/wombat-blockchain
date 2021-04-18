require 'super_diff/rspec'
require 'blockchain'


RSpec.describe Blockchain do
  describe 'viewing the chain'

  describe 'genesis block' do
    let(:block) { described_class.new(chain: [])[0] }
    it('has an index of 0') { expect(block[:index]).to eq 0 }
    it('has a timestamp of now') do
      expect(block[:timestamp]).to be_within(1).of(Time.now.to_f)
    end
    it('has no transactions') { expect(block[:transactions]).to eq [] }
    it('has a proof of 0') { expect(block[:proof]).to eq 0 }
    it('has a previous_hash of 0') { expect(block[:previous_hash]).to eq 0 }
  end

  describe 'mining' do
  end
end
