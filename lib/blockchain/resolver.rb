require 'net/http'
require 'uri'
require 'set'
require 'blockchain'

class Blockchain
  class Resolver
    include ValidProof

    attr_reader :nodes, :difficulty

    def initialize(nodes: Set.new, difficulty:)
      @nodes = nodes
      @difficulty = difficulty
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
        .filter_map { |node|
          Net::HTTP.get_response node rescue nil
        }
        .select { |response| response.code == '200' }
        .filter_map { |resp| JSON.parse(resp.body, symbolize_names: true)[:chain] }
        .select { |chain| valid_chain? chain }
        .max_by(&:size)

      return nil if longest_neighbour_chain.size <= chain.size
      Blockchain.new chain: longest_neighbour_chain, difficulty: @difficulty
    end

    def valid_chain?(chain)
      chain.each_cons 2 do |prev, crnt|
        return false unless crnt.fetch(:previous_hash) == hash_for(prev)
        return false unless valid_proof? prev.fetch(:proof), crnt.fetch(:proof), @difficulty
      end
      true
    end
  end
end
