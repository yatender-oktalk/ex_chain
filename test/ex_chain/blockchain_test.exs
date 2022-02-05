defmodule ExChain.BlockchainTest do
  @moduledoc """
  This module contains test related to a blockchain
  """

  use ExUnit.Case

  alias ExChain.Blockchain

  describe "Blockchain" do
    setup [:initialize_blockchain]

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

    test "should not be empty" do
      blockchain = %Blockchain{chain: []}

      # should invalidate the blockchain
      refute Blockchain.valid_chain?(blockchain)
    end

    test "should start with the genesis block", %{blockchain: blockchain} do
      %Blockchain{chain: [_genesis_block | rest_of_chain]} =
        blockchain
        |> Blockchain.add_block("blockchain-data-block-1")
        |> Blockchain.add_block("blockchain-data-block-2")

      blockchain = %Blockchain{blockchain | chain: rest_of_chain}

      # should invalidate the blockchain
      refute Blockchain.valid_chain?(blockchain)
    end

    test "when we tamper data in existing chain", %{
      blockchain: blockchain
    } do
      blockchain =
        blockchain
        |> Blockchain.add_block("blockchain-data-block-1")
        |> Blockchain.add_block("blockchain-data-block-2")
        |> Blockchain.add_block("blockchain-data-block-3")

      # validate if blockchain is valid
      assert Blockchain.valid_chain?(blockchain)

      for {block, index} <- Enum.with_index(blockchain.chain) do
        # tamper the blockchain, assume at location 2
        tampered_block = put_in(block.data, "tampered_data")

        tampered_blockchain = %Blockchain{chain: List.replace_at(blockchain.chain, index, tampered_block)}

        # should invalidate the blockchain
        refute Blockchain.valid_chain?(tampered_blockchain)
      end
    end

    test "when we tamper hash in existing chain", %{
      blockchain: blockchain
    } do
      blockchain =
        blockchain
        |> Blockchain.add_block("blockchain-data-block-1")
        |> Blockchain.add_block("blockchain-data-block-2")
        |> Blockchain.add_block("blockchain-data-block-3")

      # validate if blockchain is valid
      assert Blockchain.valid_chain?(blockchain)

      for {block, index} <- Enum.with_index(blockchain.chain) do
        # tamper the blockchain, assume at location 2
        tampered_block = put_in(block.hash, "tampered_hash")

        tampered_blockchain = %Blockchain{chain: List.replace_at(blockchain.chain, index, tampered_block)}

        # should invalidate the blockchain
        refute Blockchain.valid_chain?(tampered_blockchain)
      end
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
