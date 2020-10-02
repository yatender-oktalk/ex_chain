defmodule ExChain.Blockchain do
  @moduledoc """
  This module contains the blockchain related functions
  """
  alias __MODULE__
  alias ExChain.Blockchain.Block

  require Logger

  defstruct ~w(chain)a

  @type t :: %Blockchain{
          chain: [Block.t({})]
        }

  @spec new :: Blockchain.t()
  def new() do
    %__MODULE__{}
    |> add_genesis()
  end

  @spec add_block(BlockChain.t(), any) :: BlockChain.t()
  def add_block(blockchain = %__MODULE__{chain: chain}, data) do
    {last_block, _} = List.pop_at(chain, -1)

    %{blockchain | chain: chain ++ [Block.mine_block(last_block, data)]}
  end

  @spec valid_chain?(Blockchain.t()) :: boolean()
  def valid_chain?(%__MODULE__{chain: chain}) do
    chain
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.all?(fn [prev_block, block] ->
      valid_last_hash?(prev_block, block) && valid_block_hash?(prev_block)
    end)
  end

  @spec replace_chain_if_longer(ExChain.Blockchain.t(), ExChain.Blockchain.t()) ::
          ExChain.Blockchain.t()
  def replace_chain_if_longer(
        %Blockchain{chain: chain} = _blockchain,
        %Blockchain{chain: received_chain} = _received_blockchain
      ) do
    case length(received_chain) < length(chain) do
      true ->
        Logger.debug("Received chain is not longer than the current chain")
        %Blockchain{chain: chain}

      false ->
        Logger.debug("Replacing the chain")
        %Blockchain{chain: received_chain}
    end
  end

  # Private functions

  defp valid_last_hash?(
         %Block{hash: hash} = _last_block,
         %Block{last_hash: last_hash} = _current_block
       ) do
    hash == last_hash
  end

  defp valid_block_hash?(current_block) do
    current_block.hash == Block.block_hash(current_block)
  end

  defp add_genesis(blockchain = %__MODULE__{}) do
    %{blockchain | chain: [Block.genesis()]}
  end
end
