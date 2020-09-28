defmodule ExChain.BlockchainTest do
  @moduledoc """
  This module contains test related to a blockchain
  """

  use ExUnit.Case

  alias ExChain.Blockchain
  alias ExChain.Blockchain.Block

  describe "Blockchain" do
    setup [:initialize_blockchain]

    test "should start with the genesis block", %{blockchain: blockchain} do
      assert %Block{
               data: "genesis data",
               hash: "F277BF9150CD035D55BA5B48CB5BCBE8E564B134E5AD0D56E439DD04A1528D3B",
               last_hash: "-",
               timestamp: 1_599_909_623_805_627
             } == hd(blockchain.chain)
    end

    test "adds a new block", %{blockchain: blockchain} do
      data = "foo"
      blockchain = Blockchain.add_block(blockchain, data)
      [_, block] = blockchain.chain
      assert block.data == data
    end

    test "validate a chain", %{blockchain: blockchain} do
      # add block into blockchain
      blockchain = Blockchain.add_block(blockchain, "some-block-data")
      # assert if blockchain is valid
      assert Blockchain.valid_chain?(blockchain)
    end

    test "when we temper data in existing chain", %{
      blockchain: blockchain
    } do
      blockchain =
        blockchain
        |> Blockchain.add_block("blockchain-data-block-1")
        |> Blockchain.add_block("blockchain-data-block-2")
        |> Blockchain.add_block("blockchain-data-block-3")

      # validate if blockchain is valid
      assert Blockchain.valid_chain?(blockchain)
      # temper the blockchain, assume at location 2
      index = 2
      tempered_block = put_in(Enum.at(blockchain.chain, index).data, "tempered_data")

      blockchain = %Blockchain{chain: List.replace_at(blockchain.chain, index, tempered_block)}

      # should invalidate the blockchain
      refute Blockchain.valid_chain?(blockchain)
    end

    test "when we temper hash in existing chain", %{
      blockchain: blockchain
    } do
      blockchain =
        blockchain
        |> Blockchain.add_block("blockchain-data-block-1")
        |> Blockchain.add_block("blockchain-data-block-2")
        |> Blockchain.add_block("blockchain-data-block-3")

      # validate if blockchain is valid
      assert Blockchain.valid_chain?(blockchain)
      # temper the blockchain, assume at location 2
      index = 2
      tempered_block = put_in(Enum.at(blockchain.chain, index).hash, "tempered_hash")

      blockchain = %Blockchain{chain: List.replace_at(blockchain.chain, index, tempered_block)}

      # should invalidate the blockchain
      refute Blockchain.valid_chain?(blockchain)
    end
  end

  describe "Multiple chains" do
    setup [:setup_chains]

    test "longest chain wins", %{blockchain: chain_1, longer_blockchain: chain_2} do
      assert chain_2 ==
               Blockchain.replace_chain_if_longer(chain_1, chain_2)
    end

    test "longest chain wins when we send short chain", %{
      blockchain: chain_1,
      longer_blockchain: chain_2
    } do
      assert chain_2 = Blockchain.replace_chain_if_longer(chain_2, chain_1)
    end
  end

  defp initialize_blockchain(context), do: Map.put(context, :blockchain, Blockchain.new())

  defp setup_chains(context) do
    blockchain =
      Blockchain.new()
      |> Blockchain.add_block("first-block")
      |> Blockchain.add_block("second-block")
      |> Blockchain.add_block("third-block")

    longer_blockchain =
      Blockchain.new()
      |> Blockchain.add_block("first-block")
      |> Blockchain.add_block("second-block")
      |> Blockchain.add_block("third-block")
      |> Blockchain.add_block("fourth-block")

    context
    |> Map.put(:blockchain, blockchain)
    |> Map.put(:longer_blockchain, longer_blockchain)
  end
end
